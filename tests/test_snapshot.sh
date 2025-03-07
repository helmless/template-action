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

# Default chart from action.yaml
DEFAULT_CHART="oci://ghcr.io/helmless/google-cloudrun-service"

# Default options
FORCE_UPDATE=false
CI_MODE=false
VERBOSE=false

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
    -h|--help)
      echo "Usage: $0 [options]"
      echo "Options:"
      echo "  -u, --update    Force update the snapshot"
      echo "  -c, --ci        Run in CI mode (no colors, no interactive prompts)"
      echo "  -v, --verbose   Show more detailed output"
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

# Function to generate the manifest
generate_manifest() {
  echo -e "${YELLOW}Generating manifest from Helm chart...${NC}"
  
  helm template ${DEFAULT_CHART} \
    -f ${VALUES_FILE} \
    > ${TEMP_OUTPUT}
    
  if [ $? -ne 0 ]; then
    echo -e "${RED}Failed to generate manifest!${NC}"
    exit 1
  fi
  
  echo -e "${GREEN}Manifest generated successfully!${NC}"
  
  if [ "$VERBOSE" = true ]; then
    echo -e "${BLUE}Generated manifest:${NC}"
    cat ${TEMP_OUTPUT}
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
  diff_output=$(diff -u ${SNAPSHOT_FILE} ${TEMP_OUTPUT} || true)
  
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