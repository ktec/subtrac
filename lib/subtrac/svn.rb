#!/usr/bin/env ruby
# Copyright (c) 2009, Keith Salisbury (www.globalkeith.com)
# All rights reserved.
# All the svn stuff should go in here...

require 'fileutils'

module Subtrac

  class Svn
 
    class << self

      def install
        unless File.directory?(Config.svn_dir)
          File.create_if_missing(Config.svn_dir)
          hooks_dir = File.join(Config.svn_dir,".hooks")
          File.create_if_missing(hooks_dir)
          FileUtils.cp_r(Dir.glob(File.join(Config.subtrac_path, "svn/contrib/.")),hooks_dir)
        end
      end
  
      # creates a new svn repository for the project
      def create_project(project)
        
        update_project(project)
  
        # TODO: Need to handle this exception...
        if (File.directory? project.svn_dir) then
          raise StandardError, "A project called #{project.display_name} already exists in the #{project.client.display_name} repository. Please delete it or choose an alternate project name and run this script again."
        end
              
        # create a new subversion repository
        say("Creating a new subversion repository...")
        `svnadmin create #{project.svn_dir}`
  
        # import into svn
        say("Importing temporary project into the new subversion repository...")
        `svn import #{project.template}/svn file:///#{project.svn_dir} --message "initial import"`
  
        # this should fix the 'can't open activity db error'
        `sudo chmod 770 #{project.svn_dir}`
        activites_file = File.join(project.svn_dir,"/dav/activities")
        if File.exists?(activites_file)
          `sudo chmod 755 #{activites_file}`
          `sudo chown www-data:www-data #{activites_file}`
        end
        
        # install default post commit hook
        hook_file = File.join(project.svn_dir,"hooks","post-commit")
        Template.new(File.join(Config.subtrac_path, "svn", "post-commit.erb")).write(hook_file)
        `sudo chmod +x #{hook_file}`

      end
      
      def update_project(project)
  
        # get the client for this project
        client = project.client
  
        # create the client folder
        File.create_if_missing(File.join(Config.svn_dir,client.path))
  
        # create the project folder
        project.svn_dir = File.join(Config.svn_dir,client.path,project.path)
        
      end
            
    end

  end

end
