module Symfony
  class Deployer
    # much of this lifted from webistrano lib/webistrano/deployer.rb

    include Capistrano::CLI::Execute, Capistrano::CLI::Options

    attr_accessor :tasks
    attr_accessor :roles
    attr_accessor :roles_options
    attr_accessor :vars
    attr_accessor :options
    attr_accessor :config

    def initialize
      @config = Capistrano::Configuration.new
      @options = {
          :recipes => [],
          :actions => [],
          :vars => {},
          :pre_vars => {},
          :verbose => 1
      }
    end

    def execute!
      @config.load 'deploy'

      set_up_config(@config)

      @config.trigger(:load)
      execute_requested_actions(@config)
      @config.trigger(:exit)
    end

    def set_up_config(config)
      set_pre_vars(config)
      load_recipes(config)

      set_config_vars(config)
      set_roles(config)

      config.load(:string => @tasks)
      config
    end

    # sets the stage configuration on the Capistrano configuration
    def set_config_vars(config)
      @vars.each do |k, v|
        config.set k.to_sym, Deployer.type_cast(v)
      end
    end

    # sets the roles on the Capistrano configuration
    def set_roles(config)
      @roles.each do |role|

        # create role attributes hash
        role_attr = @roles_options[role[:name]]

        if role_attr.nil?
          config.role role[:name], role[:host]
        else
          config.role role[:name], role[:host], role_attr
        end
      end
    end

    # casts a given string to the correct Ruby value
    # e.g. 'true' to true and ':sym' to :sym
    def self.type_cast(val)
      return nil if val.nil?

      val.strip!
      case val
        when 'true'
          true
        when 'false'
          false
        when 'nil'
          nil
        when /\A\[(.*)\]/
          $1.split(',').map{|subval| type_cast(subval)}
        when /\A\{(.*)\}/
          $1.split(',').collect{|pair| pair.split('=>')}.inject({}) do |hash, (key, value)|
            hash[type_cast(key)] = type_cast(value)
            hash
          end
        else # symbol or string
          if cvs_root_defintion?(val)
            val.to_s
          elsif val.index(':') == 0
            val.slice(1, val.size).to_sym
          elsif match = val.match(/'(.*)'/) || val.match(/"(.*)"/)
            match[1]
          else
            val
          end
      end
    end

    def self.cvs_root_defintion?(val)
      val.index(':') == 0 && val.scan(":").size > 1
    end

  end
end
