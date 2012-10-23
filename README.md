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

Example of using hub-deploy with jenkins. It deploys from the jenkins job's workspace using the :copy deploy method.

    hub-deploy --application ${JOB_NAME} --app-servers ${app_servers} --actions ${actions} --ssh-keys ${ssh_keys} \
        --symfony-env-prod ${symfony_env_prod} --gem-tasks symfony_dev --repository ${WORKSPACE}

Another example that checks out the project from git using the :remote_cache deploy method.

    hub-deploy --actions deploy --app-servers 127.0.0.1 --deploy-to /web/hub --ssh-keys /root/.ssh/id_rsa \
         --user ec2-user --repository git@github.com:cbsi/hub --branch staging
         --deploy-via :remote_cache  --gem-tasks symfony_dev --symfony-env-prod dev --application hub

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










