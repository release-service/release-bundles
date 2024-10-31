# update-component-sbom

Tekton task to update component-level SBOMs with purls containing release-time info.

## Parameters

| Name                | Description                                                              | Optional | Default value |
|---------------------|--------------------------------------------------------------------------|----------|---------------|
| dataJsonPath        | Path to the JSON string of the merged data containing the release notes  | No       | -             |
| downloadedSbomPath  | Path to the directory holding previously downloaded SBOMs to be updated. | No       | -             |
