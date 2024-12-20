# update-component-sbom

Tekton task to update component-level SBOMs with purls containing release-time info.

## Parameters

| Name               | Description                                                              | Optional | Default value |
|--------------------|--------------------------------------------------------------------------|----------|---------------|
| sbomJsonPath       | Path to the JSON string of the merged data containing the release notes  | No       | -             |
| downloadedSbomPath | Path to the directory holding previously downloaded SBOMs to be updated. | No       | -             |

## Changes in 0.2.0
- Rename dataPath parameter to sbomJsonPath to better reflect usage

## Changes in 0.1.1
- (ISV-5321) Set a `name` of SPDX document to external reference of the component. The name is set to external image pullspec given by the public registry + repository + digest. Example: registry.redhat.io/ubi8/ubi-minimal@sha256:1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef.
