#!/usr/bin/env ruby
# Copyright (c) 2009, Keith Salisbury (www.globalkeith.com)
# All rights reserved.
# All the trac stuff should go in here...

require 'fileutils'
require 'subtrac/template'
require 'subtrac/config'

module Subtrac
  
  class Trac

    class << self

      def install
        File.create_if_missing(Config.trac_dir)
        install_common_files()
      end
      
      # Install the shared trac.ini file
      def install_common_files
        File.create_if_missing(File.join(Config.trac_dir, ".shared"))
        # install trac.ini
        trac_ini_template = Template.new(File.join(File.dirname(__FILE__), "trac", "common.trac.ini.erb"))
        trac_ini_template.write(File.join(Config.trac_dir,".shared","trac.ini"))
      end
      
      def create_project(project)
        
        update_project(project)
  
        # create new project directories
        say("Create project directories...")
        File.create_if_missing(project.trac_dir)
  
        # create a new trac site
        say("Creating a new trac site...")
        result = `trac-admin #{project.trac_dir} initenv #{project.path} sqlite:#{project.trac_dir}/db/trac.db svn #{project.svn_dir}`
        FileUtils.chown_R('www-data', 'www-data', project.trac_dir, :verbose => false) if result
  
        say("Installing trac configuration...")
        # install project trac.ini
        trac_ini_template = Template.new(File.join(File.dirname(__FILE__), "trac", "trac.ini.erb"))
        trac_ini_template.write(File.join(project.trac_dir,"/conf/trac.ini"))
        
        say("Setting up default trac permissions...")
        # set up trac permissions
        Config.trac_permissions.each do |key, value|
          `sudo trac-admin #{project.trac_dir} permission add #{key} #{value}`
        end
        
        say("Adding default trac wiki pages...#{project.template}")
        # loop through the directory and import all pages
        Dir.foreach("#{project.template}/trac/wiki/.") do |file|
          unless ['.', '..','.svn'].include? file
            temp_file = File.join(Config.tmp_dir,file)
            template = Template.new(File.join(project.template,"trac/wiki",file))
            template.write(temp_file)
            `trac-admin #{project.trac_dir} wiki import #{file} #{temp_file}`
            FileUtils.rm(temp_file)
          end
        end
  
        # run trac upgrade
        say("Upgrading the trac installation...")
        `trac-admin #{project.trac_dir} upgrade`
  
      end
  
      def update_project(project)
        client = project.client
        project.trac_dir = File.join(Config.trac_dir,client.path,project.path)
      end
          
      def admin(command)
        # loop through the directory and import all pages
        Dir.foreach(File.join(Config.trac_dir,"/.")) do |client|
          unless ['.', '..','.svn','.shared'].include? client
            Dir.foreach(File.join(Config.trac_dir,client,"/.")) do |project|
              unless ['.', '..','.svn'].include? project
                  project_dir = File.join(Config.trac_dir,client,project)
                  say("Running the command...#{command} on #{project_dir}")
                  `sudo trac-admin #{project_dir} #{command}`
              end
            end
          end
        end
      end
      
    end

  end
end
