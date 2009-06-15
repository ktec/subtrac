#!/usr/bin/env ruby
# Copyright (c) 2009, Keith Salisbury (www.globalkeith.com)
# All rights reserved.
# All the apache stuff should go in here...

require 'subtrac/template'

module Subtrac

  class Apache
    
    class << self
    
      def install
        create_virtual_host()
        configure_admin_user()
				create_htgroups_file()
      end

      def create_virtual_host()
        puts "\n==== Creating new virtual host ===="
        # TODO: Place a file in apache2 conf with Include directive which points to our conf folder
        file_name = File.join(Config.apache_conf_dir,Config.server_hostname)
        get_template("vhost.conf.erb").write(file_name)
        # this template links to the apache directory, so we must create it now
        File.create_if_missing(Config.apache_dir)
        enable_site()
        force_reload()
      end

			def create_htgroups_file
				# create client group file
				htgroups_file = File.join(Config.apache_dir,".auth","htgroups")
				get_template("htgroups.erb").write(htgroups_file)
			end

      # creates the files necessary for a new client
      def create_client(client)
        client_config = File.join(Config.apache_dir,"#{Config.client.path}.conf")
        unless File.exists?(client_config)
          get_template("location.conf.erb").write(client_config)
          force_reload()
        end
				# add client group to htgroups file
				File.open(File.join(Config.apache_dir,".auth","htgroups"), "a+") do |file|
					unless file =~ /#{client.path}\:/
						# add a new line
						file.write("#{client.path}:")
					end
				end
=begin 
# delete client group from htgroups
File.open(f, "w") do |out|
	File.foreach(fb) do |line| 
		out.puts line unless line =~ /preg/  # $. == 5
	end
end
=end
      end

      def force_reload
        # reload apache configuration
        `/etc/init.d/apache2 force-reload` if SUBTRAC_ENV != 'test'
        say("Apache reloaded...")
      end

      def enable_site
        # tell apache enable site
        `a2ensite #{Config.server_hostname}` if SUBTRAC_ENV != 'test'
        puts("Apache site enabled...")
      end

      def create_project(project)
        # we dont need to do anything for each project, but we do need to ensure a client location exists
        create_client(project.client)
      end

      def get_template(name)
        Template.new(File.join(File.dirname(__FILE__), "apache", name))
      end

      def configure_admin_user
        puts "\n==== Configure admin user ===="
        # create admin user
        admin_user = ask("New admin user:  ") { |q| q.echo = true }
        admin_pass = ask("New password:  ") { |q| q.echo = "*" }
        admin_pass_confirm = ask("Re-type new password:  ") { |q| q.echo = "*" }
        if (admin_pass == admin_pass_confirm) then
          File.create_if_missing(Config.auth_dir)
          passwd_file = File.join(Config.auth_dir, "htpasswds")
          `htpasswd -c -b #{passwd_file} #{admin_user} #{admin_pass}`
          Config.data[:admin_user] = admin_user
          Config.data[:admin_pass] = admin_pass
          # ensure this guy is added to trac admin group
          Config.data[:trac][:permissions][admin_user] = "admins"
        else
          # call the password chooser again
          configure_admin_user()
        end
      end

      def give_apache_privileges
        # make sure apache can operate on these files
        `sudo chown -R www-data:www-data #{Config.install_dir}`
      end
  
    end
    
  end

end
