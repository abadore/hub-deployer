#!/bin/sh
gem build hub-deployer.gemspec
gem install hub-deployer-0.0.1.dev.gem

application="${JOB_NAME}"
if [ -z "${application}" ] ; then application="hub"; fi

repository="${WORKSPACE}"
if [ -z "${repository}" ] ; then repository=""; fi

app_servers="${app_servers}"
if [ -z "${app_servers}" ] ; then app_servers=""; fi

actions="deploy"

deploy_to="/web/hub"

user="ec2-user"

ssh_keys=""

symfony_env_prod="dev"

keep_releases=3


export tasks=$(cat <<EOS

set :application,         "${application}"
set :deploy_to,           "${deploy_to}"

set :repository,          "${repository}"
set :local_repository,    "${repository}"
set :deploy_via,          :copy

set :scm,                 :git
set :ssh_keys,            "${ssh_keys}"

set :keep_releases,       "${keep_releases}"
set :php_bin,             "php"
set :remote_tmp_dir,      "/tmp"

set :sudo_prompt,         ""
set :use_sudo,            false

set :user,                "${user}"
set :password,            ""
set :symfony_env_prod,    "${symfony_env_prod}"

# Be more verbose by uncommenting the following line
logger.level = Logger::MAX_LEVEL

# allocate a pty by default as some systems have problems without
default_run_options[:pty] = true

set :use_sudo, 		    true

# Symfony application path
set :app_path,              "app"

# Symfony web path
set :web_path,              "web"

# Symfony console bin
set :symfony_console,       app_path + "/console"

# Symfony log path
set :log_path,              app_path + "/logs"

# Symfony cache path
set :cache_path,            app_path + "/cache"

# Symfony bin vendors
set :symfony_vendors,       "bin/vendors"

# Symfony build_bootstrap script
set :build_bootstrap,       "bin/build_bootstrap"

# Whether to use composer to install vendors.
# If set to false, it will use the bin/vendors script
set :use_composer,          true

# Whether to update vendors using the configured dependency manager (composer or bin/vendors)
set :update_vendors,        false

# run bin/vendors script in mode (upgrade, install (faster if shared /vendor folder) or reinstall)
set :vendors_mode,          "reinstall"

# Whether to run cache warmup
set :cache_warmup,          true

# Use AsseticBundle
set :dump_assetic_assets,   true

# Assets install
set :assets_install,        true
set :assets_symlinks,       false
set :assets_relative,       false

# Whether to update `assets_version` in `config.yml`
set :update_assets_version, false

# Need to clear *_dev controllers
set :clear_controllers, false

# Files that need to remain the same between deploys
set :shared_files,          false

# Dirs that need to remain the same between deploys (shared dirs)
set :shared_children,       [log_path, web_path + "/uploads"]

# Asset folders (that need to be timestamped)
set :asset_children,        [web_path + "/css", web_path + "/images", web_path + "/js"]

# Dirs that need to be writable by the HTTP Server (i.e. cache, log dirs)
set :writable_dirs,         [log_path, cache_path]

# Name used by the Web Server (i.e. www-data for Apache)
set :webserver_user,        "apache"

# Method used to set permissions (:chmod, :acl, or :chown)
set :permission_method,    :chown

# Model manager: (doctrine, propel)
set :model_manager,         "doctrine"

# Symfony2 version
set(:symfony_version)       { guess_symfony_version }

# If set to false, it will never ask for confirmations (migrations task for instance)
# Use it carefully, really!
set :interactive_mode,      false

before "deploy:finalize_update" do
  if !remote_file_exists?("#{latest_release}/app/config/parameters.ini")
    logger.important("--> Copy #{latest_release}/app/config/parameters.sample.ini to #{latest_release}/app/config/parameters.ini")
    run "cp #{latest_release}/app/config/parameters.sample.ini #{latest_release}/app/config/parameters.ini"
    run "cp #{latest_release}/web/app_dev.php #{latest_release}/web/index.php"
  end
end

after "deploy:finalize_update" do
  deploy.set_permissions
end

before "deploy:rollback" do
  deploy.set_permissions
end


EOS)

hub-deploy --app-servers ${app_servers}
