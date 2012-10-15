#!/bin/sh

hub-deploy --application ${JOB_NAME} --app-servers ${app_servers} --actions ${actions} --ssh-keys ${ssh_keys} \
    --symfony-env-prod ${symfony_env_prod} --gem-tasks symfony_dev --repository ${WORKSPACE}
