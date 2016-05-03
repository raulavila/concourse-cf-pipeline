#Concourse

- Create alias for the API: `fly --target tutorial login  --concourse-url http://192.168.100.4:8080`
- Synchronized with the API just aliased: `fly -t tutorial sync`

## Running basic commands

In Concourse, the central concept is to run tasks. This example runs a single
task configured in a YAML file:

`fly -t tutorial execute -c task_hello_world.yml`

```
---
platform: linux

image: docker:///busybox

run:
  path: echo
  args: [hello world]
```


## Task inputs

The following YAML configures an input for the task:

```
---
platform: linux

image: docker:///busybox

inputs:
- name: 02_task_inputs

run:
  path: ls
  args: ['-alR']
```

A new folder in the container called `02_task_inputs` will be created at
`./02_task_inputs`. This input must be mapped to a folder. If the name of the
folder containing the file matches the input name we don't need to provide any
additional argument:

`fly -t tutorial e -c input_parent_dir.yml`

If the name of the folder doesn't match we have to specify it, i.e. if we
want the input to be the folder containing the YAML file:

`fly -t tutorial e -c inputs_required.yml -i 02_task_inputs=.`

### Scripts as inputs

If we include a script in the input folder we can access it using `run`:

```
platform: linux
image: docker:///busybox

inputs:
- name: 03_task_scripts

run:
  path: ./03_task_scripts/task_show_uname.sh
```


## Pipelines

`fly -t tutorial set-pipeline -c pipeline.yml -p helloworld [-n]`

Will create a pipeline called `helloworld` with all the jobs configured in
`pipeline.yml`, i.e.:

```
---
jobs:
- name: job-hello-world
  public: true
  plan:
  - task: hello-world
    config:
      platform: linux
      image: docker:///busybox
      run:
        path: echo
        args: [hello world]
```

Upon creation, the pipeline is paused by default. To unpause:

`fly -t tutorial unpause-pipeline -p helloworld`

We can see the pipeline in the GUI:
`http://192.168.100.4:8080/pipelines/helloworld`

As his job has no schedule or triggers to run the pipeline you must first
select the job and then click the `+` icon to run it.

To destroy a pipeline (and lose all the history):

`fly destroy-pipeline -t tutorial -p helloworld`

### Resources

A resource is an input or output external to the pipeline codebase.

```
---
resources:
- name: resource-tutorial
  type: git
  source:
    uri: https://github.com/starkandwayne/concourse-tutorial.git

jobs:
- name: job-hello-world
  public: true
  plan:
  - get: resource-tutorial
  - task: hello-world
    file: resource-tutorial/01_task_hello_world/task_hello_world.yml
```

There are several built-in resources, and it's possible to add bespoke
community resources too.

### Trigger

A job run can be triggered if certain events happen to a resource. For instance,
a new commit is made in a Git repo:

```
---
resources:
- name: resource-tutorial
  type: git
  source:
    uri: https://github.com/starkandwayne/concourse-tutorial.git

jobs:
- name: job-hello-world
  public: true
  plan:
  - get: resource-tutorial
    trigger: true
  - task: hello-world
    file: resource-tutorial/01_task_hello_world/task_hello_world.yml
```

There is a `time` resource, to schedule jobs:

```
resources:
- name: my-timer
  type: time
  source:
    interval: 2m
```    

### Resources as task input

TODO: update with Maven configuration

```
---
platform: linux

image: docker:///[DOCKER_IMAGE]

inputs:
- name: resource-tutorial
- name: resource-app

run:
  path: resource-tutorial/10_job_inputs/task_run_tests.sh
```  
