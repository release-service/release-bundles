# cosign-sign

Sign container image with given identity and manifest digest using cosign.

## Parameters

| Name             | Description                                                                                                  | Optional | Default value |
|------------------|--------------------------------------------------------------------------------------------------------------|----------|---------------|
| identity         | Docker identity for the signed content, e.g. registry.redhat.io/ubi9/ubi:latest                              | No       | -             |
| reference        | Docker reference for the signed content, e.g. quay.io/redhat-pending/ubi9----ubi:latest                      | No       | -             |
| digest           | Manifest digest for the signed content, usually in the format sha256:xxx                                     | No       | -             |
| signature_exists | Identification whether signature already exists. Positive non-zero value indicates, signature exists         | No       | -             |
| secretName       | Name of secret containing  AWS_DEFAULT_REGION, AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, SIGN_KEY, REKOR_URL | No       | -             |

## Changes in 0.1.1
  * Fix linting issues in this task

    - name: identity
      description: Docker reference for the signed content, e.g. registry.stage.redhat.io/ubi8/ubi:latest
      type: string
    - name: reference
      description: Docker reference container image to be signed, e.g. quay.io/redhat-pending/ubi8----ubi:latest
      type: string
    - name: digest
      description: Manifest digest for the signed content
      type: string
    - name: signature_exists
      type: string
      description: Number of signatures found for the given image and manifest digest
    - name: secretName
      description: Name of secret containing needed credentials
      type: string
