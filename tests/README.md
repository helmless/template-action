# Snapshot Testing

This directory contains snapshot tests for the Helmless Template GitHub Action.

## Files

- `values.yaml`: Sample values file used for testing the template
- `snapshot.yaml`: Expected output from templating the chart with the values
- `test_snapshot.sh`: Script to run the snapshot test

## Running Tests

To run the snapshot test:

```bash
./test_snapshot.sh
```

### Options

- `--update` or `-u`: Force update the snapshot
- `--ci` or `-c`: Run in CI mode (no colors, no interactive prompts)
- `--verbose` or `-v`: Show more detailed output
- `--help` or `-h`: Show help message

## CI Integration

The snapshot tests are integrated into the CI workflow and run automatically on pull requests and pushes to main.

There's also a manual workflow to update the snapshot if needed. This can be triggered from the GitHub Actions tab.

## How It Works

The test script:

1. Templates the Helm chart using the values in `values.yaml`
2. Compares the output with the expected snapshot in `snapshot.yaml`
3. If they match, the test passes
4. If they don't match, the test fails and shows the diff

When running locally, you'll be prompted to update the snapshot if the test fails. In CI mode, the test will just fail. 