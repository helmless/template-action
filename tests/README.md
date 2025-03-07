# Snapshot Testing

This directory contains snapshot tests for the Helmless Template GitHub Action.

## Files

- `values.yaml`: Sample values file used for testing the template
- `snapshot.yaml`: Expected output from templating the chart with the values
- `test_snapshot.sh`: Script to run the snapshot test
- `output/`: Temporary directory where individual templates are stored during testing

## Running Tests

To run the snapshot test:

```bash
./test_snapshot.sh
```

### Options

- `--update` or `-u`: Force update the snapshot
- `--ci` or `-c`: Run in CI mode (no colors, no interactive prompts)
- `--verbose` or `-v`: Show more detailed output including full template contents
- `--no-print` or `-n`: Don't print rendered templates
- `--help` or `-h`: Show help message

## CI Integration

The snapshot tests are integrated into the CI workflow and run automatically on pull requests and pushes to main.

There's also a manual workflow to update the snapshot if needed. This can be triggered from the GitHub Actions tab.

## How It Works

The test script:

1. Templates the Helm chart using the values in `values.yaml` and outputs to a directory
2. Finds all template files in the output directory
3. Combines them into a single file for snapshot comparison
4. Displays a summary of each template (kind and name)
5. Compares the combined output with the expected snapshot in `snapshot.yaml`
6. If they match, the test passes
7. If they don't match, the test fails and shows the diff

When running locally, you'll be prompted to update the snapshot if the test fails. In CI mode, the test will just fail. 