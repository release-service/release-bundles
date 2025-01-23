# embargo-check

Tekton task to check if any issues or CVEs in the releaseNotes key of the data.json are embargoed. It checks the issues
by server using curl and checks the CVEs via an InternalRequest. If any issue or CVE is embargoed, the task will fail.

## Parameters

| Name                     | Description                                                                               | Optional | Default value |
|--------------------------|-------------------------------------------------------------------------------------------|----------|---------------|
| dataPath                 | Path to data JSON in the data workspace                                                   | No       | -             |
| requestTimeout           | InternalRequest timeout                                                                   | Yes      | 180           |
| pipelineRunUid           | The uid of the current pipelineRun. Used as a label value when creating internal requests | No       | -             |
| taskGitUrl               | The url to the git repo where the release-service-catalog tasks to be used are stored     | No       | -             |
| taskGitRevision          | The revision in the taskGitUrl repo to be used                                            | No       | -             |

## Changes in 0.5.0
* Added taskGiturl and taskGitRevision parameters to be passed to the internalRequest
* The pipeline is called via git resolver now instead of cluster resolver
  * This was done by changing from `-r` to `--pipeline` in the `internal-request` call
  * The base image was updated to include this new functionality
* Updated logic to determine InternalRequest name more reliably

## Changes in 0.4.1
* fix linting issues in embargo-check task 

## Changes in 0.4.0
* updated the base image used in this task

## Changes in 0.3.0
* updated the base image used in this task

## Changes in 0.2.0
* remove `dataPath` default value
