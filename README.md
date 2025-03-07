# helmless/template-action

![Version](https://img.shields.io/github/v/release/helmless/template-action)
![License](https://img.shields.io/github/license/helmless/template-action)

The [helmless/template-action](https://github.com/helmless/template-action) is a GitHub Action to template a Helmless chart into a serverless manifest.

You most likely want to use this together with the `*-deploy-action` matching your cloud provider.  
Right now only the [helmless/google-cloudrun-deploy-action](https://github.com/helmless/google-cloudrun-deploy-action) exists, but more will follow soon.
By default the action will use the [helmless/google-cloudrun-chart](https://github.com/helmless/google-cloudrun-chart) chart, but you can override this by setting the `chart` input.

<!-- x-release-please-start-version -->
<!-- action-docs-usage action="action.yaml" project="helmless/template-action" version="v0.1.0" -->
### Usage

```yaml
- uses: helmless/template-action@v0.1.0
  with:
    chart:
    # Helm chart to use for templating. Defaults to the Google Cloud Run chart.
    #
    # Required: false
    # Default: oci://ghcr.io/helmless/google-cloudrun-service

    chart_version:
    # Version of the Helm chart to use.
    #
    # Required: false
    # Default: latest

    files:
    # Glob patterns of value files to include when templating the chart.
    #
    # Required: false
    # Default: values.yaml

    values:
    # Additional values to pass to the Helm chart when templating. Use one line per key-value pair.
    #
    # Required: false
    # Default: ""

    override_values:
    # Override values to pass to the Helm chart when templating. These values are set last and will override any other values. Use one line per key-value pair.
    #
    # Required: false
    # Default: ""

    print_manifest:
    # If true, print the rendered manifest to the console.
    #
    # Required: false
    # Default: true

    output_path:
    # The path to output the combined manifest to.
    #
    # Required: false
    # Default: helmless_manifest.yaml

    output_dir:
    # Directory to output individual template files to. If not specified, a temporary directory will be used.
    #
    # Required: false
    # Default: ""
```
<!-- action-docs-usage action="action.yaml" project="helmless/template-action" version="v0.1.0" -->
<!-- x-release-please-end -->

<!-- action-docs-inputs source="action.yaml" -->
### Inputs

| name | description | required | default |
| --- | --- | --- | --- |
| `chart` | <p>Helm chart to use for templating. Defaults to the Google Cloud Run chart.</p> | `false` | `oci://ghcr.io/helmless/google-cloudrun-service` |
| `chart_version` | <p>Version of the Helm chart to use.</p> | `false` | `latest` |
| `files` | <p>Glob patterns of value files to include when templating the chart.</p> | `false` | `values.yaml` |
| `values` | <p>Additional values to pass to the Helm chart when templating. Use one line per key-value pair.</p> | `false` | `""` |
| `override_values` | <p>Override values to pass to the Helm chart when templating. These values are set last and will override any other values. Use one line per key-value pair.</p> | `false` | `""` |
| `print_manifest` | <p>If true, print the rendered manifest to the console.</p> | `false` | `true` |
| `output_path` | <p>The path to output the combined manifest to.</p> | `false` | `helmless_manifest.yaml` |
| `output_dir` | <p>Directory to output individual template files to. If not specified, a temporary directory will be used.</p> | `false` | `""` |
<!-- action-docs-inputs source="action.yaml" -->

<!-- action-docs-outputs source="action.yaml" -->
### Outputs

| name | description |
| --- | --- |
| `manifest` | <p>The rendered manifest from the Helm chart as YAML.</p> |
| `manifest_path` | <p>The path to the rendered manifest.</p> |
| `template_count` | <p>The number of templates rendered.</p> |
| `output_dir` | <p>The directory containing the individual template files.</p> |
<!-- action-docs-outputs source="action.yaml" -->
