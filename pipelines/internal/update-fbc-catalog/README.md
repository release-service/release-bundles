# update-fbc-catalog pipeline

Tekton pipeline add/update FBC fragments to the FBC catalog by interacting with IIB service for File Based Catalogs

## Parameters

| Name                    | Description                                                                 | Optional | Default value       |
|-------------------------|-----------------------------------------------------------------------------|----------|---------------------|
| iibServiceAccountSecret | Secret containing the credentials for IIB service                           |   yes    | iib-service-account |
| fbcFragment             | FBC fragment built by HACBS                                                 |   no     | -                   |
| fromIndex               | Index image (catalog of catalogs) the FBC fragment will be added to         |   no     | -                   |
| buildTags               | List of additional tags the internal index image copy should be tagged with |   yes    | '[]'                |
| addArches               | List of arches the index image should be built for                          |   yes    | '[]'                |
| hotfix                  | Whether this build is a hotfix build                                        |   yes    | false               |
| stagedIndex             | Whether this build is a staged index build                                  |   yes    | false               |
| buildTimeoutSeconds     | IIB Build Service timeout seconds                                           |   no     | -                   |
