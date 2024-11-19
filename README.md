# helmless/template-action

![Version](https://img.shields.io/github/v/release/helmless/template-action)
![License](https://img.shields.io/github/license/helmless/template-action)

The [helmless/template-action](https://github.com/helmless/template-action) is a GitHub Action to template a Helmless chart into a serverless manifest.

You most likely want to use this together with the `*-deploy-action` matching your cloud provider.  
Right now only the [helmless/google-cloudrun-deploy-action](https://github.com/helmless/google-cloudrun-deploy-action) exists, but more will follow soon.
By default the action will use the [helmless/google-cloudrun-chart](https://github.com/helmless/google-cloudrun-chart) chart, but you can override this by setting the `chart` input.

<!-- x-release-please-start-version -->
<!-- action-docs-usage action="action.yaml" project="helmless/template-action" version="v0.1.0" -->
<!-- x-release-please-end -->

<!-- action-docs-inputs source="action.yaml" -->

<!-- action-docs-outputs source="action.yaml" -->
