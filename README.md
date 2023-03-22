jigarthanda
===========

# Creating a Custom Dashboard with Relevant Charts

This guide will explain the step through the process of creating a custom dashboard with relevant charts and variables in Grafana. It will also show you how to export the dashboard JSON, modify it, and prepare it for use in Terraform Enterprise Grafana onboarding process.

## 1. Create a dashboard with relevant charts

First, create a new dashboard in Grafana and add the relevant charts you want to display. Pre-built panels or custom panels can be used based on the requirements of the application team.

## 2. Create a custom dashboard variable

To create a custom variable that can filter the data, follow these steps:

1. Click on the **Dashboard settings** (gear icon) in the upper right corner of the dashboard.
2. Navigate to the **Variables** tab and click on **New**.
3. Choose the variable type of Custom, give it a name, and configure its options as needed.
4. Save the variable.

## 3. Modify the data_profiles list object in the thd_teams definition

In in the variables.tf file, find the `thd_teams` definition and update the `data_profiles` list object to create a list using a name that makes sense for your use case. The examplename provided below demonstrates how to create an optional object with different data profiles.

```hcl
data_profiles = list(object({
  type        = string
  kosmos      = optional(object({
    cluster_ids = list(string)
  })),
  vantage  = optional(object({
    service_ids = list(string)
  })),
  vault  = optional(object({
    namespace = list(string)
  })),
  examplename = optional(object({
    example_object = list(string)
  })),
}))
```

## 4. Export the dashboard JSON

To export the dashboard JSON:

1. Click on the **Dashboard settings** (gear icon) in the upper right corner of the dashboard.
2. Navigate to the **JSON Model** tab.
3. Click on the **Copy to Clipboard** button to copy the entire JSON content.

## 5. Remove the "id" from the JSON

Open a text editor, paste the JSON content, and locate the `"id"` field near the top of the file. Remove the entire line containing the `"id"` field. If this step isn't completed, the resulting dashboard will likely fail due to the id not being found, or already in use by the API. For example, change:

```json
{
  "editable": true,
  "fiscalYearStartMonth": 0,
  "graphTooltip": 0,
  "id": 336,
  "links": [],
  "liveNow": false,
  "panels": [
```
to:
```json
{
  "editable": true,
  "fiscalYearStartMonth": 0,
  "graphTooltip": 0,
  "links": [],
  "liveNow": false,
  "panels": [
```
## 6. Remove Prometheus datasource blocks
In the JSON file, remove all datasource blocks of type `prometheus`. You can leave the `grafana` datasource at the top. Removing these blocks ensures that the dashboard template can be reused even if the datasource ID changes. This is because the default data source for Enterprise Grafana is the GMP data source.
Example:
```json
"datasource": {
  "type": "prometheus",
  "uid": "HniOlTlnz"
},
```
## 7. Add dashboard and folderUid sections
Add the required `dashboard` and `folderUid` sections to the JSON for proper dashboard creation and folder assignment. Without these sections, the Grafana API will return a bad request (missing dashabord section), or the dashboard will be placed in the general folder (missing folderUid). The folderUid will be populated by the target customer's folder during the Terraform workflow.
```json
{
  "dashboard":{
    "annotations": {
      ...
      "version": 1
    },
    "folderUid": "{{ .folder_uid }}"
}
```
## 8. Locate and modify the custom variable
Find the custom variable created in Step 2 within the JSON file's `templating` section. Modify the template section to match the same pattern shown in the below examples.
Example 1:
Example data_profile:
```hcl
vault  = optional(object({
namespace = list(string)
})),
```
Example templated dashboard:
```json
{{ if gt (len $.vault.namespace) 0 }},
        {
            "current": {
            "selected": false,
            "text": "{{index .vault.namespace 0}}",
            "value": "{{index .vault.namespace 0}}"
            },
            "hide": 0,
            "includeAll": false,
            "label": "namespace",
            "multi": false,
            "name": "namespace",
            "options": [{{ range $i, $namespace := .vault.namespace }}
            {
                "selected": true,
                "text": "{{ $namespace }}",
                "value": "{{ $namespace }}"
            }{{ if ne (inc $i) (len $.vault.namespace) }},{{ end }}
            {{ end }}],
            "query": "namespace",
            "skipUrlSync": false,
            "type": "custom"
        }
        {{ end }}
        ]
    },
```
Example 2:
Example data_profile:
```hcl
vantage  = optional(object({
service_ids = list(string)
})),
```
Example templated dashboard:
```json
{{ if gt (len .vantage.service_ids) 0 }},
            {
              "current": {
                "selected": false,
                  "text": "{{ index .vantage.service_ids 0 }}",
                  "value": "{{ index .vantage.service_ids 0 }}"
              },
              "hide": 0,
              "includeAll": false,
              "label" : "Vantage Service",
              "multi": false,
              "name": "service",
              "options": [{{ range $i, $service := .vantage.service_ids }}
                {
                  "selected": true,
                  "text": "{{ $service }}",
                  "value": "{{ $service }}"
                }{{ if ne (inc $i) (len $.vantage.service_ids) }},{{ end }}
              {{ end }}],
              "query": "service1",
              "skipUrlSync": false,
              "type": "custom"
            }
            {{ end }}
        ]
    },
```
Example 3:

Example data_profile:

```hcl
kosmos      = optional(object({
cluster_ids = list(string)
})),
```
Example templated dashboard

```json
{ if gt (len $.kosmos.cluster_ids) 0 }},
            {
                "current": {
                "selected": false,
                "text": "{{index .kosmos.cluster_ids 0}}",
                "value": "{{index .kosmos.cluster_ids 0}}"
                },
                "hide": 0,
                "includeAll": false,
                "multi": false,
                "name": "cluster",
                "options": [{{ range $i, $cluster := .kosmos.cluster_ids }}
                  {
                    "selected": true,
                    "text": "{{ $cluster }}",
                    "value": "{{ $cluster }}"
                  }{{ if ne (inc $i) (len $.kosmos.cluster_ids) }},{{ end }}
                {{ end }}],
                "query": "cluster1",
                "skipUrlSync": false,
                "type": "custom"
            }
            {{ end }}
            ]
        }
```

Ensure that you compare your data_profile with the examples and adjust them accordingly. Save the file after making the changes.

## 9. Save the dashboard with the data_profile name

Save the dashboard using the same name used in the new `data_profile` object. The name of the `data_profile` is what is used to determine which dashboard template to use. Example: kosmos `data_profile` dashboard is named `kosmos.tmpl`

## 10. Push your code to GitHub

Push the branch containing the modified JSON file to the [enterprise-grafana-terraform repository](https://github.com/one-thd/enterprise-grafana-terraform) repository.

## 11. Create a Pull Request

Create a Pull Request and request review from Casey Flanigan, Roshan D'Souza, Pavan Nadipelli, or Jaxon Pickett.

You can find examples of properly configured dashboard templates in the [enterprise-grafana-terraform repository](https://github.com/one-thd/enterprise-grafana-terraform/tree/main/dashboards).
