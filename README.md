Hub Deployer
============
Hub deployer is a ruby gem for deploying Symfony 2 apps

Installation
--------
System Dependencies

 * ruby devel
 * gcc
 * libxml2
 * libxslt
 * libxml2 devel
 * libxslt devel

If installing on OS X please refer to the dependency installation in [nokogiri install instructions](http://nokogiri.org/tutorials/installing_nokogiri.html)

Executables
------

 * hub-deploy - for deploying symfony apps
 * cloud-deploy - deploying AWS CloudFormation stacks

hub-depoy Usage
-------
Options

 * --actions : Actions to perform (default: deploy)
 * --app-servers : Servers to deploy to
 * --application : Name of application (default: hub)
 * --deploy-to : Deploy directory (default: /web/hub)
 * --symfony-env-prod : Symfony environment to deploy (default: prod)
 * --user : Remote user (default: ec2-user)
 * --password : Remote user password
 * --ssh-keys : SSH key file
 * --keep-releases : Number of releases to keep (default: 3)
 * --php-bin : PHP binary (default: php)
 * --deploy-via : Capistrano deploy method (default: :copy)
 * --scm : SCM type (default: :git)
 * --repository : SCM repository location
 * --branch : SCM branch/tag
 * --use-sudo : Use sudo
 * --tasks : Tasks file
 * --gem-tasks : Internal tasks file
 * --use-scp : Use scp instead of sftp
 * --build-local : Build local then copy to remotes
 * --remote-tasks : Tasks file to run on remotes, use with build_local
 * --local-user : Remote user (default: ec2-user)
 * --local-actions : Local actions to perform (default: deploy)
 * --local-password : Remote user password
 * --local-ssh-keys : Remote user SSH key file
 * --local-deploy-to : Local deploy directory (default: /web/hub)
 * --ec2-tag : Deploy to EC2 instances with this tag (tag_name=tag_value)
 * --ec2-region : EC2 Region where instances are located (default: us-east-1)
 * --aws-access-key-id : AWS Access Key ID
 * --aws-secret_access_key : AWS Secret Key

Example of using hub-deploy with jenkins. It deploys from the jenkins job's workspace using the :copy deploy method.

    hub-deploy --application ${JOB_NAME} --app-servers ${app_servers} --actions ${actions} --ssh-keys ${ssh_keys} \
        --symfony-env-prod ${symfony_env_prod} --gem-tasks symfony_dev --repository ${WORKSPACE}

Another example that checks out the project from git using the :remote_cache deploy method.

    hub-deploy --actions deploy --app-servers 127.0.0.1 --deploy-to /web/hub --ssh-keys /root/.ssh/id_rsa \
         --user ec2-user --repository git@github.com:cbsi/hub --branch staging \
         --deploy-via :remote_cache  --gem-tasks symfony_dev --symfony-env-prod dev --application hub

Example of build locally then deploy to remotes. The --build-local flag will run capistrano twice, once on the local build server, once to copy the successful local build to the app servers.
--tasks/--gem-tasks are run locally and --remote-tasks are run on the app servers.

    hub-deploy --actions deploy --app-servers ${app_servers} --deploy-to /www/fly --ssh-keys ${ssh_keys} \
     --user ec2-user --repository git@github.com:cbsi/fly-techrepublic --branch master --deploy-via :remote_cache \
     --tasks ${fly_tasks} --symfony-env-prod dev --application fly --local-deploy-to ${WORKSPACE}/fly --remote-tasks ${copy_tasks} \
     --build-local --local-user ec2-user --local-ssh-keys ${ssh_keys} --use-scp

Example of deploying to EC2 Instances in region us-west-1 with a tag named deploy_id with the value QA

    hub-deploy --actions deploy --deploy-to /web/hub --ssh-keys /root/.ssh/id_rsa \
         --user ec2-user --repository git@github.com:cbsi/hub --branch staging \
         --deploy-via :remote_cache  --gem-tasks symfony_dev --symfony-env-prod dev --application hub \
         --ec2-tag deploy_id=QA --ec2-region us-west-1 --aws-access-key-id ${access_id} --aws-secret-access-key ${secret}



cloud-deploy Usage
-------
Options

 * --aws-access-key-id : AWS Access Key ID
 * --aws-secret-access-key : AWS Secret Key
 * --aws-region : AWS Region (default: us-west-1)
 * --stack-name : CloudFormation Stack Name
 * --cf-template : CloudFormation Template
 * --parameters : CF Template Parameters (comma delimited name=value pairs)
 * --delete-first : Delete Prior Stack
 * --update : Update Stack
 * --disable-rollback : Disable Rollback










