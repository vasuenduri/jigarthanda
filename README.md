![MongoDB Workflows](https://github.com/vasuenduri/jigarthanda/blob/master/mongodb-ar21.svg)
# Skynet Mongodb
> This repo contains actions workflows i.e a configurable automated process that will run one or more mongoDB jobs.

## Table of Contents
* [General Info](#general-information)
* [Technologies Used](#technologies-used)
* [Setup](#setup)
* [Usage](#usage)
* [Acknowledgements](#acknowledgements)
* [Contact](#contact)

## General Information
- GitHub Actions, a workflow is an automated process that you set up in the same place where you store code and collaborate on pull requests and issues.
- This repo consists such workflows targeting various requirements like triggering a job upon the pull request, run the cronjobs, manually run the jobs depends on the inputs etc.
- This setup helps devs to fasten the testing process after commiting the changes and also reduce the dependency on devops for the CI/CD process.

## Technologies Used
- Github Actions - version 1.0.0
- Ansible - version 2.6.1

## Setup

The below table provides the basic intro on the automation jobs/workflows this repo handles.

| Workflow Name | Action | Description Link |
| ------------- | ------------- | --------  |
| Skynet-Docker-image-build-push   | Pushing the docker images to repo  | [Skynet-Docker-image-build-push](https://confluence.primetherapeutics.com/display/SKYNET/MongoDB%3A+How+to+use+Skynet-Docker-Image-build-push.yaml+workflow) | 
| Skynet-MongoDb-Adhoc-commands-execution | MongoDB commands  | [Skynet-MongoDb-Adhoc-commands-execution]() |
| Skynet-MongoDb-Delete-Namespace | Action to delete tanzu kubernetes namespace  | [Skynet-MongoDb-Delete-Namespace](https://github.com/Lord-of-the-Repos/skynet-mongodb/blob/main/.github/workflows/Skynet-MongoDB-Delete-Namespace.yaml) |
| Skynet-MongoDb-Deploy-Apikey-Secret | MongoDB Api keys deployment  | [Skynet-MongoDb-Deploy-Apikey-Secret](https://confluence.primetherapeutics.com/pages/viewpage.action?pageId=475104694) |
| Skynet-MongoDb-Deploy-Pvc-storage-update | PersistentVolumeClaim storage update  | [Skynet-MongoDb-Deploy-Pvc-storage-update](https://confluence.primetherapeutics.com/display/SKYNET/MongoDB%3A+How+to+use+Skynet-MongoDB-Deploy-pvc-storage-update.yaml+workflow) |
| Skynet-MongoDb-Deploy-helm-pem | MongoDB helm deployment  | [Skynet-MongoDb-Deploy-helm-pem](https://confluence.primetherapeutics.com/pages/viewpage.action?pageId=475104694) |
| Skynet-MongoDb-Deploy-pem-secrets | Action to deploy the secrets into k8s cluster  | [Skynet-MongoDb-Deploy-pem-secrets](https://confluence.primetherapeutics.com/display/SKYNET/MongoDB%3A+How+to+create+a+pem+file+and+store+the+pem+file+as+a+kubernetes+secret) |
| Skynet-MongoDb-Dump-Multiple-Collections | Action to take dump of multiple collections  | [Skynet-MongoDb-Dump-Multiple-Collections](https://confluence.primetherapeutics.com/display/SKYNET/MongoDB%3A+How+to+use+Skynet-MongoDB-Dump-Multiple-Collections.yaml+workflow) |
| Skynet-MongoDb-Ops-Manager-Automation | MongoDB Ops Manager  | [Skynet-MongoDb-Ops-Manager-Automation]() |
| Skynet-MongoDb-Restore-Collection | Restore the specified collection into cluster | [Skynet-MongoDb-Restore-Collection]() |
| Skynet-MongoDb-Restore-Multiple-collections | Restore the multiple collections into cluster  | [Skynet-MongoDb-Restore-Multiple-collections](https://confluence.primetherapeutics.com/display/SKYNET/MongoDB%3A+How+to+use+Skynet-MongoDB-Restore-Multiple-collections.yaml+workflow) |
| Skynet-MongoDb-Snapshot-restore | MongoDB Snapshot restore  | [Skynet-MongoDb-Snapshot-restore]() |
| Skynet-MongoDb-Sts-pvc-delete | Action to delete PersistentVolumeClaim  | [Skynet-MongoDb-Sts-pvc-delete](https://confluence.primetherapeutics.com/display/SKYNET/MongoDB%3A+How+to+use+Skynet-MongoDB-sts-pvc-delete.yaml+workflow) |
| Skynet-MongoDb-create-namespace | Action to create tanzu kubernetes namespace  | [Skynet-MongoDb-create-namespace](https://confluence.primetherapeutics.com/pages/viewpage.action?pageId=475104694) |
| Skynet-MongoDb-Agent-version-update | MongoDB agents version upgrade  | [Skynet-MongoDb-Agent-version-update](https://confluence.primetherapeutics.com/display/SKYNET/MongoDB%3A+How+to+use+Skynet-Mongodb-Agent-version-update.yaml+workflow) |


## Usage
Workflows can be triggered using the Actions tab on GitHub, GitHub CLI, or the REST API. We will discuss on how to run the workflow manually through web browser.

- On GitHub.com, navigate to the main page of the repository.
- Under your repository name, click  Actions.

  ![Actions](https://docs.github.com/assets/cb-21779/mw-1440/images/help/repository/actions-tab.webp?raw=true)

- In the left sidebar, click the name of the workflow you want to run.

  ![Actions](https://docs.github.com/assets/cb-60479/mw-1440/images/help/repository/actions-select-workflow-2022.webp?raw=true)

- Above the list of workflow runs, click the Run workflow button.

  ![Actions](https://docs.github.com/assets/cb-52943/mw-1440/images/help/actions/actions-workflow-dispatch.webp?raw=true)

- Select the Branch dropdown menu and click a branch to run the workflow on.
- If the workflow requires input, fill in the fields.
- Click Run workflow.

The following link provide more info on other methods to run the github workflows [manually-running-a-workflow](https://docs.github.com/en/actions/using-workflows/manually-running-a-workflow)

## Acknowledgements
- Github Actions tutorial [Intro](https://docs.github.com/en/actions).


## Contact
Created by [Author](https://github.com/PTBXXXXX_PTI)
