# update-internal-services-manager

Tekton pipeline to update the internal-services manager yaml to the latest image in the
hacbs-release/app-interface-deployments repository.

## Parameters

| Name         | Description                                                                                            | Optional | Default value |
|--------------|--------------------------------------------------------------------------------------------------------|----------|---------------|
| release      | The namespaced name (namespace/name) of the Release custom resource initiating this pipeline execution | No       | -             |
| repoUrl      | The repository where the internal-services manager files to update are                                 | No       | -             |
| githubSecret | The secret containing a TOKEN key to authenticate with GitHub to the repoUrl                           | No       | -             |
