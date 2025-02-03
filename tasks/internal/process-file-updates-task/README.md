# process-file-updates-task

Tekton Task to update files in Git repositories. It is possible to seed a file with initial content and/or apply
replacements to a yaml file that already exists. It will attempt to create a Merge Request in Gitlab.

## Parameters

| Name                           | Description                                                                                                                                                                              | Optional | Default value                            |
| ------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- | ---------------------------------------- |
| upstream_repo                  | Upstream Git repository                                                                                                                                                                  | No       | -                                        |
| repo                           | Git repository                                                                                                                                                                           | No       | -                                        |
| ref                            | Git branch                                                                                                                                                                               | No       | -                                        |
| paths                          | String containing a JSON array of file paths and its updates and/or replacements E.g. '[{"path":"file1.yaml","replacements":[{"key":".yamlkey1,","replacement":"\|regex\|replace\|"}]}]' | No       | -                                        |
| application                    | Application being released                                                                                                                                                               | No       | -                                        |
| file_updates_secret            | The credentials used to update the git repo                                                                                                                                              | Yes      | file-updates-secret                      |
| tempDir                        | temp dir for cloning and updates                                                                                                                                                         | Yes      | /tmp/$(context.taskRun.uid)/file-updates |
| internalRequestPipelineRunName | name of the PipelineRun that called this task                                                                                                                                            | No       | -                                        |

## Changes in 0.0.2
* add new `internalRequestPipelineRunName` parameter and result
  - Tekton only supports passing task results as pipeline results,
    so we need to pass the PLR name to the task first and then emit it from the task
