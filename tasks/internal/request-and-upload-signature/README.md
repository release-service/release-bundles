# request-and-upload-signature

Task to request and upload signatures using RADAS and pyxis

## Parameters

| Name                       | Description                                                                                                            | Optional | Default value                                         |
|----------------------------|------------------------------------------------------------------------------------------------------------------------|----------|-------------------------------------------------------|
| pipeline_image             | An image with CLI tools needed for the signing.                                                                        | Yes      | quay.io/redhat-isv/operator-pipelines-images:released |
| manifest_digests           | Space separated manifest digests for the signed content, usually in the format sha256:xxx                              | No       | -                                                     |
| references                 | Space separated docker references for the signed content, e.g. registry.redhat.io/redhat/community-operator-index:v4.9 | No       | -                                                     |
| requester                  | Name of the user that requested the signing, for auditing purposes                                                     | No       | -                                                     |
| sig_key_id                 | The signing key id that the content is signed with                                                                     | Yes      | 4096R/55A34A82 SHA-256                                |
| sig_key_name               | The signing key name that the content is signed with                                                                   | Yes      | containerisvsign                                      |
| pyxis_ssl_cert_secret_name | Kubernetes secret name that contains the Pyxis SSL files                                                               | No       | -                                                     |
| pyxis_ssl_cert_file_name   | The key within the Kubernetes secret that contains the Pyxis SSL cert.                                                 | No       | -                                                     |
| pyxis_ssl_key_file_name    | The key within the Kubernetes secret that contains the Pyxis SSL key.                                                  | No       | -                                                     |
| umb_client_name            | Client name to connect to umb, usually a service account name                                                          | Yes      | operatorpipelines                                     |
| umb_listen_topic           | umb topic to listen to for responses with signed content                                                               | Yes      | VirtualTopic.eng.robosignatory.isv.sign               |
| umb_publish_topic          | umb topic to publish to for requesting signing                                                                         | Yes      | VirtualTopic.eng.operatorpipelines.isv.sign           |
| umb_url                    | umb host to connect to for messaging                                                                                   | Yes      | umb.api.redhat.com                                    |
| umb_ssl_cert_secret_name   | Kubernetes secret name that contains the umb SSL files                                                                 | No       | -                                                     |
| umb_ssl_cert_file_name     | The key within the Kubernetes secret that contains the umb SSL cert.                                                   | No       | -                                                     |
| umb_ssl_key_file_name      | The key within the Kubernetes secret that contains the umb SSL key.                                                    | No       | -                                                     |
| pyxis_url                  | Pyxis instance to upload the signature to.                                                                             | Yes      | https://pyxis.engineering.redhat.com                  |
| pyxis_threads              | Number of threads to use when uploading signatures                                                                     | Yes      | 5                                                     |
| signature_data_file        | The file where the signing response should be placed                                                                   | Yes      | signing_response.json                                 |

## Changes in 2.0.0
  * Use pubtools-sign and pubtools-pyxis in quay.io/konflux-ci/release-service-utils to request and upload signatures
  * Signatures are now requested in batches of references+digests instead of one reference+digest per internal request

## Changes in 1.0.0
  * Replaced `ssl_cert_secret_name`, `ssl_cert_file_name` and `ssl_key_file_name` parameters with Pyxis and UMB
    specific ones
    * This allows us to use the stage version of one system with the prod version of the other
