#!/usr/bin/env ruby
# Copyright (c) 2009, Keith Salisbury (www.globalkeith.com)
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that the following conditions are met:
# 
# Redistributions of source code must retain the above copyright notice,
# this list of conditions and the following disclaimer.
# 
# Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation
# and/or other materials provided with the distribution.
# 
# Neither the name of the original author nor the names of contributors
# may be used to endorse or promote products derived from this software
# without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

require 'yaml'
require 'erb'
require 'fileutils'
require 'subtrac/version'
require 'subtrac/commands'
require 'subtrac/client'
require 'subtrac/project'
require 'subtrac/apache'
require 'subtrac/svn'
require 'subtrac/trac'
require 'subtrac/core_ext'
require 'subtrac/config'

module Subtrac

  SUBTRAC_ROOT = "#{File.dirname(__FILE__)}/" unless defined?(SUBTRAC_ROOT)
  SUBTRAC_ENV = (ENV['SUBTRAC_ENV'] || 'development').dup unless defined?(SUBTRAC_ENV)
  
  class << self
  
    # Loads the configuration YML file
    def load_config
      Config.load() if !Config.loaded?
    end

    # Install
    def install(args,options)
      
      load_config()

      puts "\n==== Installing development server files ===="
    
      if options.defaults then
        overwrite = options.clean
        confirm_default_client = true
      else
        # check where we are installing
        Config.confirm_or_update(:install_dir,"install_dir")
      
        unless !File.directory?(Config.install_dir)
          # Ask if the user agrees (yes or no)
          confirm_clean = agree("Err, it seems there's some stuff in there. You sure you want me to overwrite? [Y/n]") if options.clean
          overwrite = agree("Doubly sure? I can't undo this....[Y/n]") if confirm_clean
        end

        # confirm server
        Config.confirm_or_update(:server_name,"server_name")

        # ask for hostname
        Config.confirm_or_update(:server_hostname,"server_hostname")

        # default client/project name
        Config.confirm_or_update(:default_client,"default_client")
        Config.confirm_or_update(:default_project,"default_project")

      end
    
      say("Ok we're about to install now, these are the options you have chosen:
      installation directory: #{Config.install_dir}
      overwrite: #{overwrite}
      server name: #{Config.server_name}
      server hostname: #{Config.server_hostname}
      default client: #{Config.default_client}
      default project: #{Config.default_project}")

      confirm = agree("Is this ok? [y/n]")  
    
      exit 0 if !confirm
    
      create_environment_directories(overwrite)
      install_common_files()

      # create the trac site
      Apache.install()
      Svn.install()
      Trac.install()
    
      # create default project
      create_project(Config.default_project,Config.default_client,"blank")

      # store any user preferences for later use
      Config.save()

    end

    def delete_project(project,client)

      load_config()

      if client
        # test the client exists
        client_exists = Dir.exist?(File.join(Config.svn_dir,client))
      end

      unless client or client_exists
        list_of_clients = Dir.entries(Config.svn_dir)
        choose do |menu|
          menu.prompt = "Which client contains the project you would like to delete?  "
          list_of_clients.each do |t|
            unless File.directory?(t) 
							# TODO: or (Dir.entries(t).size - 2 > 0) test for empty client folders
              menu.choice t do client = t end
            end
          end
        end
      end

      if project
        # test the project exists
        project_exists = Dir.exist?(File.join(Config.svn_dir,client,project))
      end
 
      unless project or project_exists
        list_of_projects = Dir.entries(File.join(Config.svn_dir,client))
        choose do |menu|
          menu.prompt = "Which project would you like to delete?  "
          list_of_projects.each do |t|
            unless File.directory?(t)
              menu.choice t do project = t end
            end
          end
        end
      end

      # remove the folder
      archive = ask("Would you like a backup of this project? [y/n]")

      if archive
        # create default project
        project = Project.new(project,client,"blank")
        project.archive()
      end

      project.delete()
      
    end
  
    def create_project(project,client,template=nil)

      load_config()

      project = ask("What is the name of the project you would like to create? ") if project.nil?
      client = ask("Which client is this project for? ") if client.nil?
      use_custom_template = agree("Would you like to use a custom template for this project? [y/n]") if template.nil?
      if use_custom_template then
        list_of_templates = Dir.entries(File.join(Config.svn_dir,"templates"))
        choose do |menu|
          menu.prompt = "Which template would you like to use for this project?  "
          list_of_templates.each do |t|
            unless File.directory?(t)
              menu.choice t do template = t end
            end
          end
        end
      else
        template = "blank"
      end

      # create default project
      project = Project.new(project,client,template)
    
      # get these out for binding...we'll tidy up later
      #client = project.client
      Config.project = project
      Config.client = project.client
      
      project.create()

      # fix privileges
      Apache.give_apache_privileges()
    
    end

    def trac_admin(str)
      load_config()
      # create the trac site
      Trac.admin(str)
    end

    private
  
      def install_common_files    
        puts "\n==== Installing common files ===="
        # TODO: implement a mask for .svn folders
        # TODO: refactor /common to the app config
        File.create_if_missing Config.docs_dir
        FileUtils.cp_r(Dir.glob(File.join(Config.subtrac_path, "common/.")),Config.docs_dir)
      end
    
      def create_environment_directories(overwrite=false)
        puts "\n==== Creating new environment directories ===="
        FileUtils.rm_rf Config.install_dir if overwrite
        File.create_if_missing Config.install_dir
        File.create_if_missing Config.tmp_dir
        File.create_if_missing Config.log_dir
        # create the environment directories
        #Config.data[:dirs].each do |key, value|
        #  dir = File.join(Config.install_dir,value)
        #  File.create_if_missing dir
        #end
      end
    
  end

end



