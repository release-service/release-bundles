# extract-artifacts

Tekton task that extracts binaries using oras and saves them in a workspace

## Parameters

| Name            | Description                                                       | Optional | Default value                                            |
|-----------------|-------------------------------------------------------------------|----------|----------------------------------------------------------|
| snapshot_json   | String containing a JSON representation of the snapshot spec      | No       | -                                                        |
| concurrentLimit | The maximum number of images to be pulled at once                 | Yes      | 3                                                        |
