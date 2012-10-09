require 'capistrano'
require 'capistrano/cli'
require 'symfony/deployer'

#ENV.each do |k, v|
#  puts "#{k} => #{v}"
#end

tasks = <<-'EOS'
    load 'deploy' if respond_to?(:namespace) # cap2 differentiator
    load Gem.find_files('symfony2.rb').first.to_s

    set :application,         "#{ENV['JOB_NAME']}"
    set :deploy_to,           "#{ENV['deploy_to']}"
    set :app_path,            "#{ENV['symfony_app_path']}"

    set :repository,          "#{ENV['WORKSPACE']}"
    set :local_repository,    "#{ENV['WORKSPACE']}"
    set :deploy_via,          :copy

    set :scm,                 :git
    set :ssh_keys,            "#{ENV['ssh_keys']}"

    set :keep_releases,       "#{ENV['keep_releases']}"
    set :php_bin,             "php"
    set :remote_tmp_dir,      "/tmp"

    set :sudo_prompt,         ""
    #set :use_sudo,            false

    set :user,                 "#{ENV['user']}"
    set :password,            ""
    set :symfony_env_prod,    "#{ENV['symfony_env_prod']}"

    # Be more verbose by uncommenting the following line
    logger.level = Logger::MAX_LEVEL

    # allocate a pty by default as some systems have problems without
    default_run_options[:pty] = true

    # set Net::SSH ssh options through normal variables
    # at the moment only one SSH key is supported as arrays are not
    # parsed correctly by Webistrano::Deployer.type_cast (they end up as strings)
    [:ssh_port, :ssh_keys].each do |ssh_opt|
      if exists? ssh_opt
        logger.important("SSH options: setting #{ssh_opt} to: #{fetch(ssh_opt)}")
        ssh_options[ssh_opt.to_s.gsub(/ssh_/, '').to_sym] = fetch(ssh_opt)
      end
    end

    desc <<-DESC
      Prepares one or more servers for deployment. Before you can use any \
      of the Capistrano deployment tasks with your project, you will need to \
      make sure all of your servers have been prepared with `cap deploy:setup'. When \
      you add a new server to your cluster, you can easily run the setup task \
      on just that server by specifying the HOSTS environment variable:

        $ cap HOSTS=new.server.com deploy:setup

      It is safe to run this task on servers that have already been set up; it \
      will not destroy any deployed revisions or data.
    DESC
    task :setup, :roles => :app, :except => { :no_release => true } do
      dirs = [deploy_to, releases_path, shared_path]
      try_sudo "mkdir -p #{dirs.join(' ')}"
      try_sudo "chmod g+w #{dirs.join(' ')}" if fetch(:group_writable, true)
    end

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

EOS

tasks += ENV['symfony_params'] + "\n"

#   puts tasks

app_servers = ENV['app_servers'].split(',')
roles = []
app_servers.each do |host|
  roles.push(
    {
      :name => :app,
      :host => host
    }
  )
end


roles_options = {
}

vars = {}

deployer = Symfony::Deployer.new
deployer.tasks = tasks
deployer.roles = roles
deployer.roles_options = roles_options
deployer.vars = vars
deployer.options[:actions] = ENV['actions'].split(',')
deployer.options[:verbose] = 3
deployer.execute!