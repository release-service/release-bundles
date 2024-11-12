# cosign-check-signature-exists

Task to check wheter a signature exists for a given identity and manifest digest.

## Parameters

    - name: identity
      description: Docker reference for the signed content, e.g. registry.stage.redhat.io/ubi8/ubi:latest
      type: string
    - name: reference
      description: Docker reference container image to be signed, e.g. quay.io/redhat-pending/ubi8----ubi:latest
      type: string
    - name: digest
      description: Manifest digest for the signed content
      type: string
    - name: secretName
      description: Name of secret containing needed credentials
      type: string

| Name                 | Description                                                                                           | Optional | Default value                                         |
|----------------------|-------------------------------------------------------------------------------------------------------|----------|-------------------------------------------------------|
| identity             | Docker reference for the signed content, e.g. registry.stage.redhat.io/ubi8/ubi:latest                | No       | -                                                     |
| reference            | Docker reference container image to be signed, e.g. quay.io/redhat-pending/ubi8----ubi:latest         | No       | -                                                     |
| digest               | Manifest digest of the signed content                                                                 | No       | -                                                     |
| secretName           | Name of secret containing REKOR_URL and PUBLIC_KEY                                                    | No       | -                                                     |
