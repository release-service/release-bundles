# reduce-snapshot

Tekton task to reduce a snapshot to a single component based on the component that the snapshot was built for.

## Parameters

| Name                                | Description                                                                                                                 | Optional | Default value |
|-------------------------------------|-----------------------------------------------------------------------------------------------------------------------------|----------|---------------|
| SNAPSHOT                            | String representation of Snapshot spec                                                                                      | No       | -             |
| SINGLE_COMPONENT                    | Single mode component enabled                                                                                               | No       | -             |
| SINGLE_COMPONENT_CUSTOM_RESOURCE    | Custom Resource to query for built component in Snapshot                                                                    | No       | -             |
| SINGLE_COMPONENT_CUSTOM_RESOURCE_NS | Namespace where Custom Resource is found                                                                                    | No       | -             |
| SNAPSHOT_PATH                       | The location to place the reduced Snapshot                                                                                  | No       | -             |
| ociStorage                          | The OCI repository where the Trusted Artifacts are stored.                                                                  | No       | -             |
| ociArtifactExpiresAfter             | Expiration date for the trusted artifacts created in the OCI repository. An empty string means the artifacts do not expire. | Yes      | 1d            |
| sourceDataArtifact                  | Location of trusted artifacts to be used to populate data directory                                                         | No       | -             |
| subdirectory                        | Subdirectory inside the workspace to be used                                                                                | No       | -             |

## Changes in 0.2.0
* This task now supports Trusted artifacts
