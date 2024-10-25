# check-embargoed-cves pipeline

Tekton pipeline to execute the check-embargoed-cves task. The goal of the task is to ensure none of the provided
CVEs are marked as embargoed. If so, the pipeline result `result` will be the error and check `embargoed_cves`
result will be the list of embargoed CVEs.

## Parameters

| Name | Description                                                                                | Optional | Default value |
|------|--------------------------------------------------------------------------------------------|----------|---------------|
| cves | String containing a space separated list of CVEs to check (e.g. 'CVE-123 CVE-234 CVE-345') | No       | -             |
