#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VALUES_FILE="${SCRIPT_DIR}/values.yaml"
SNAPSHOT_FILE="${SCRIPT_DIR}/snapshot.yaml"
TEMP_OUTPUT="${SCRIPT_DIR}/temp_output.yaml"
OUTPUT_DIR="${SCRIPT_DIR}/output"

# Default chart from action.yaml
DEFAULT_CHART="oci://ghcr.io/helmless/google-cloudrun-service"

# Default options
FORCE_UPDATE=false
CI_MODE=false
VERBOSE=false
PRINT_TEMPLATES=true

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    -u|--update)
      FORCE_UPDATE=true
      shift
      ;;
    -c|--ci)
      CI_MODE=true
      shift
      ;;
    -v|--verbose)
      VERBOSE=true
      shift
      ;;
    -n|--no-print)
      PRINT_TEMPLATES=false
      shift
      ;;
    -h|--help)
      echo "Usage: $0 [options]"
      echo "Options:"
      echo "  -u, --update    Force update the snapshot"
      echo "  -c, --ci        Run in CI mode (no colors, no interactive prompts)"
      echo "  -v, --verbose   Show more detailed output"
      echo "  -n, --no-print  Don't print rendered templates"
      echo "  -h, --help      Show this help message"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      echo "Use --help to see available options"
      exit 1
      ;;
  esac
done

# Disable colors in CI mode
if [ "$CI_MODE" = true ]; then
  GREEN=''
  RED=''
  YELLOW=''
  BLUE=''
  NC=''
fi

# Function to generate the manifest and process templates
generate_manifest() {
  echo -e "${YELLOW}Generating manifest from Helm chart...${NC}"
  
  # Clean up any previous output directory
  rm -rf "${OUTPUT_DIR}"
  mkdir -p "${OUTPUT_DIR}"
  
  # Use Helm's output-dir flag to write templates to files
  helm template ${DEFAULT_CHART} \
    -f ${VALUES_FILE} \
    --output-dir "${OUTPUT_DIR}"
  
  if [ $? -ne 0 ]; then
    echo -e "${RED}Failed to generate manifest!${NC}"
    exit 1
  fi
  
  # Find all template files
  TEMPLATE_FILES=$(find "${OUTPUT_DIR}" -type f -name "*.yaml" | sort)
  TEMPLATE_COUNT=$(echo "${TEMPLATE_FILES}" | wc -l)
  echo -e "${GREEN}Successfully generated $TEMPLATE_COUNT template(s)${NC}"
  
  # Combine all templates into a single file for snapshot comparison
  rm -f "${TEMP_OUTPUT}"
  for template in ${TEMPLATE_FILES}; do
    # Add separator between templates
    if [ -s "${TEMP_OUTPUT}" ]; then
      echo "---" >> "${TEMP_OUTPUT}"
    fi
    cat "${template}" >> "${TEMP_OUTPUT}"
  done
  
  # Print templates if requested
  if [ "$PRINT_TEMPLATES" = true ] || [ "$VERBOSE" = true ]; then
    echo -e "${BLUE}Generated templates:${NC}"
    
    TEMPLATE_NUM=1
    for template in ${TEMPLATE_FILES}; do
      echo -e "${BLUE}Template $TEMPLATE_NUM: $(basename ${template})${NC}"
      if [ "$VERBOSE" = true ]; then
        cat "${template}"
      else
        # Extract kind and name for a summary
        KIND=$(grep "kind:" "${template}" | head -1 | awk '{print $2}')
        NAME=$(grep "name:" "${template}" | head -1 | awk '{print $2}' | tr -d '"')
        echo "Kind: ${KIND}, Name: ${NAME}"
      fi
      echo ""
      TEMPLATE_NUM=$((TEMPLATE_NUM + 1))
    done
  fi
}

# Create snapshot if it doesn't exist
create_snapshot() {
  echo -e "${YELLOW}Creating new snapshot...${NC}"
  cp ${TEMP_OUTPUT} ${SNAPSHOT_FILE}
  echo -e "${GREEN}Snapshot created at ${SNAPSHOT_FILE}${NC}"
}

# Compare the current output with the snapshot
compare_with_snapshot() {
  if [ ! -f "${SNAPSHOT_FILE}" ]; then
    echo -e "${YELLOW}Snapshot doesn't exist. Creating one...${NC}"
    create_snapshot
    return 0
  fi
  
  if [ "$FORCE_UPDATE" = true ]; then
    echo -e "${YELLOW}Forcing snapshot update...${NC}"
    create_snapshot
    return 0
  fi
  
  echo -e "${YELLOW}Comparing with snapshot...${NC}"
  # Create temporary files with helmless-chart-version lines removed
  FILTERED_SNAPSHOT=$(mktemp)
  FILTERED_OUTPUT=$(mktemp)
  
  grep -v "helmless-chart-version" ${SNAPSHOT_FILE} > ${FILTERED_SNAPSHOT} || true
  grep -v "helmless-chart-version" ${TEMP_OUTPUT} > ${FILTERED_OUTPUT} || true
  
  diff_output=$(diff -u ${FILTERED_SNAPSHOT} ${FILTERED_OUTPUT} || true)
  
  # Clean up temp files
  rm -f ${FILTERED_SNAPSHOT} ${FILTERED_OUTPUT}
  
  if [ -z "$diff_output" ]; then
    echo -e "${GREEN}✅ Test passed! Output matches snapshot.${NC}"
    rm ${TEMP_OUTPUT}
    return 0
  else
    echo -e "${RED}❌ Test failed! Output doesn't match snapshot.${NC}"
    echo -e "${YELLOW}Diff:${NC}"
    echo "$diff_output"
    
    if [ "$CI_MODE" = true ]; then
      echo "::error::Snapshot test failed. Run locally with --update to update the snapshot."
      rm ${TEMP_OUTPUT}
      return 1
    fi
    
    read -p "Do you want to update the snapshot? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      create_snapshot
    else
      echo -e "${YELLOW}Keeping the existing snapshot.${NC}"
    fi
    
    rm ${TEMP_OUTPUT}
    return 1
  fi
}

# Cleanup function
cleanup() {
  # Remove temporary output directory
  if [ -d "${OUTPUT_DIR}" ]; then
    rm -rf "${OUTPUT_DIR}"
  fi
  
  # Remove temporary output file if it exists
  if [ -f "${TEMP_OUTPUT}" ]; then
    rm -f "${TEMP_OUTPUT}"
  fi
}

# Register cleanup function to run on exit
trap cleanup EXIT

# Main execution
echo -e "${YELLOW}Starting snapshot test...${NC}"

# Check if Helm is installed
if ! command -v helm &> /dev/null; then
  echo -e "${RED}Helm is not installed. Please install Helm first.${NC}"
  if [ "$CI_MODE" = true ]; then
    echo "::error::Helm is not installed"
  fi
  exit 1
fi

# Generate the manifest
generate_manifest

# Compare with snapshot
compare_with_snapshot
result=$?

echo -e "${YELLOW}Test completed.${NC}"
exit $result 