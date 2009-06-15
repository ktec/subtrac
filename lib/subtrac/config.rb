#!/usr/bin/env ruby
# Copyright (c) 2009, Keith Salisbury (www.globalkeith.com)
# All rights reserved.
# All the config stuff should go in here...

require 'fileutils'

module Subtrac

  class Config

    class << self

      USER_CONFIG_FILE = '/tmp/subtrac_user_config.yml'

      attr_accessor :data

      def initialize()
        puts "config/initialize"
      end

      def get_binding
        binding
      end

      def loaded?
        @loaded ||= false
      end

      # Loads the configuration YML file
      def load
        # TODO: We need to refactor this code so it will load the default configuration only if one has not been created
        puts "\n==== Loading configuration file ===="
        puts "Attempting to read config file: #{config_path}"
        begin
          yamlFile = YAML.load(File.read(config_path))
        rescue Exception => e
          raise StandardError, "Config #{config_path} could not be loaded."
        end
        if yamlFile
          if yamlFile[SUBTRAC_ENV]
            @data = yamlFile[SUBTRAC_ENV]
            @loaded = true
          else
            raise StandardError, "#{config_path} exists, but doesn't have a configuration for #{SUBTRAC_ENV}."
          end
        else
          raise StandardError, "#{config_path} does not exist."
        end
        say("Configuration loaded successfully...")
      end
    
      # Write the changes configuration to disk
      def save
        # save the things that might have changed    
        user_config = {SUBTRAC_ENV => @data}
        open(USER_CONFIG_FILE, 'w') {|f| YAML.dump(user_config, f)}
      end
    
      # confirms the current value with the user or accepts a new value if required
      def confirm_or_update(prop, name)
        method(prop).call # initialise the property
        current_value = instance_variable_get("@#{prop}")
        accept_default = agree("The default value for #{prop} is \"#{current_value}\". Is this ok? [y/n]")
        if !accept_default then
          answer = ask("What would you like to change it to?")
          send("#{prop}=", answer)
          #instance_variable_set(prop, answer)
        end
      end
    
      def config_path
        # load configuration file
        file_path = USER_CONFIG_FILE
        file_path = File.join(subtrac_path,"/config/config.yml") if not File.exists?(file_path)
        @config_path ||= file_path      
      end
      
      def project
        @project
      end

      def project=(name)
        @project = name
      end
      
      def client
        @client
      end
    
      def client=(name)
        @client = name
      end

      # Admin User
      def admin_user
        @admin_user ||= @data[:admin_user]
      end

      # User configured options
      def server_name
        @server_name ||= @data[:server_name]
      end

      def server_name=(name)
        @data[:server_name] = @server_name = name
      end

      def server_hostname
        @server_hostname ||= @data[:server_hostname]
      end

      def server_hostname=(name)
        @data[:server_hostname] = @server_hostname = name
      end

      def default_client
        @default_client ||= @data[:default_client]
      end

      def default_client=(name)
        @data[:default_client] = @default_client = name
      end

      def default_project
        @default_project ||= @data[:default_project]
      end

      def default_project=(name)
        @data[:default_project] = @default_project = name
      end

      # Filesystem directories
      def root
        Pathname.new(SUBTRAC_ROOT) if defined?(SUBTRAC_ROOT)
      end

      def public_path
        @public_path ||= self.root ? File.join(self.root, "public") : "public"
      end
    
      def public_path=(path)
        @public_path = path
      end

      def subtrac_path
        @subtrac_path ||= self.root ? File.join(self.root, "subtrac") : "subtrac"
      end

      def install_dir
        @install_dir ||= File.expand_path(@data[:installation_dir])
      end

      def install_dir=(name)
        @data[:installation_dir] = @install_dir = name
      end
    
      def apache_conf_dir
        @apache_conf_dir ||= @data[:apache_conf_dir]
      end

      def apache_conf_dir=(name)
        @data[:apache_conf_dir] = @apache_conf_dir = name
      end

      def docs_dir
        @docs_dir ||= File.join(install_dir,@data[:dirs][:docs])
      end

      def svn_dir
        @svn_dir ||= File.join(install_dir,@data[:dirs][:svn])
      end

      def trac_dir
        @trac_dir ||= File.join(install_dir,@data[:dirs][:trac])
      end

      def tmp_dir
        @tmp_dir ||= File.join(install_dir,@data[:dirs][:tmp])
      end

      def log_dir
        @log_dir ||= File.join(install_dir,@data[:dirs][:log])
      end

      def auth_dir
        @auth_dir ||= File.join(install_dir,@data[:dirs][:auth])
      end

      def apache_dir
        @apache_dir ||= File.join(install_dir,@data[:dirs][:apache])
      end
    
      # Urls
      def svn_url
        @svn_url ||= @data[:urls][:svn]
      end
    
      def trac_permissions
        @trac_permissions ||= @data[:trac][:permissions]
      end
    
      # LDAP
      def enable_ldap
        @enable_ldap ||= @data[:ldap][:enable]
      end

      def enable_ldap=(value)
        @data[:ldap][:enable] = @enable_ldap = value
      end

      def ldap_host
        @ldap_host ||= @data[:ldap][:host]
      end

      def ldap_host=(value)
        @data[:ldap][:host] = @ldap_host = value
      end

      def ldap_port
        @ldap_port ||= @data[:ldap][:port]
      end

      def ldap_port=(value)
        @data[:ldap][:port] = @ldap_port = value
      end

      def ldap_basedn
        @ldap_basedn ||= @data[:ldap][:basedn]
      end

      def ldap_basedn=(value)
        @data[:ldap][:basedn] = @ldap_basedn = value
      end

      def ldap_user_rdn
        @ldap_user_rdn ||= @data[:ldap][:user_rdn]
      end

      def ldap_user_rdn=(value)
        @data[:ldap][:user_rdn] = @ldap_user_rdn = value
      end

      def ldap_group_rdn
        @ldap_group_rdn ||= @data[:ldap][:group_rdn]
      end

      def ldap_group_rdn=(value)
        @data[:ldap][:group_rdn] = @ldap_group_rdn = value
      end

      def ldap_store_bind
        @ldap_store_bind ||= @data[:ldap][:store_bind]
      end

      def ldap_store_bind=(value)
        @data[:ldap][:store_bind] = @ldap_store_bind = value
      end

      def ldap_store_bind
        @ldap_bind_password ||= @data[:ldap][:bind_password]
      end

      def ldap_bind_user
        @ldap_bind_user ||= @data[:ldap][:bind_user]
      end

      def ldap_bind_user=(value)
        @data[:ldap][:bind_user] = @ldap_bind_user = value
      end

      def ldap_bind_passwd
        @ldap_bind_passwd ||= @data[:ldap][:bind_passwd]
      end

      def ldap_bind_passwd=(value)
        @data[:ldap][:bind_passwd] = @ldap_bind_passwd = value
      end


      # SMTP
      def enable_smtp
        @enable_smtp ||= @data[:smtp][:enable]
      end

      def enable_smtp=(value)
        @data[:smtp][:enable] = @enable_smtp = value
      end

      def smtp_always_bcc
        @smtp_always_bcc ||= @data[:smtp][:always_bcc]
      end
    
      def smtp_always_bcc=(value)
        @data[:smtp][:always_bcc] = @smtp_always_bcc = value
      end

      def smtp_always_cc
        @smtp_always_cc ||= @data[:smtp][:always_cc]
      end
    
      def smtp_always_cc=(value)
        @data[:smtp][:always_cc] = @smtp_always_cc = value
      end

      def smtp_default_domain
        @smtp_default_domain ||= @data[:smtp][:default_domain]
      end
    
      def smtp_default_domain=(value)
        @data[:smtp][:default_domain] = @smtp_default_domain = value
      end
    
      def smtp_from
        @smtp_from ||= @data[:smtp][:from]
      end
    
      def smtp_from=(value)
        @data[:smtp][:from] = @smtp_from = value
      end
    
      def smtp_from_name
        @smtp_from_name ||= @data[:smtp][:from_name]
      end
    
      def smtp_from_name=(value)
        @data[:smtp][:from_name] = @smtp_from_name = value
      end
    
      def smtp_password
        @smtp_password ||= @data[:smtp][:password]
      end
    
      def smtp_password=(value)
        @data[:smtp][:password] = @smtp_password = value
      end
    
      def smtp_port
        @smtp_port ||= @data[:smtp][:port]
      end
    
      def smtp_port=(value)
        @data[:smtp][:port] = @smtp_port = value
      end
    
      def smtp_replyto
        @smtp_replyto ||= @data[:smtp][:replyto]
      end
    
      def smtp_replyto=(value)
        @data[:smtp][:replyto] = @smtp_replyto = value
      end
    
      def smtp_server
        @smtp_server ||= @data[:smtp][:server]
      end
    
      def smtp_server=(value)
        @data[:smtp][:server] = @smtp_server = value
      end
    
      def smtp_subject_prefix
        @smtp_subject_prefix ||= @data[:smtp][:subject_prefix]
      end
    
      def smtp_subject_prefix=(value)
        @data[:smtp][:subject_prefix] = @smtp_subject_prefix = value
      end
    
      def smtp_user
        @smtp_user ||= @data[:smtp][:user]
      end
    
      def smtp_user=(value)
        @data[:smtp][:user] = @smtp_user = value
      end

    end

  end

end
