# get-git-sha-image-ref-from-release

Tekton task to get the image reference containing the git sha tag from the Release artifacts.

It finds the git sha by checking for the `pac.test.appstudio.openshift.io/sha` label on the Release CR.
If it is not found, the task will fail with error.

This task is only meant to work with Releases for one component. If the task finds there are more than one image
in its artifacts, it will fail with error.

Once it has the git sha, the task simply returns the image url from the artifacts that ends with it. This is
done via the `imageRef` task result.

## Parameters

| Name                 | Description                                        | Optional | Default value |
|----------------------|----------------------------------------------------|----------|---------------|
| release              | Namespaced name of the Release                     | No       | -             |
