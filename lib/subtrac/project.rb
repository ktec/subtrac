require 'subtrac/client'

module Subtrac

  class Project
    
    attr_reader :display_name, :path, :client, :template
    attr_accessor :svn_dir, :trac_dir#, :tmp_dir

    def initialize(project_name,client_name,template)
      @display_name = project_name.gsub(/^[a-z]|\s+[a-z]/) { |a| a.upcase }
      @path = project_name.downcase.gsub(' ','_')
      @client = Client.new(client_name)
      prepare_template(template)
      # Set up svn, trac and apache
      Svn.update_project(self)
      Trac.update_project(self)
      
    end
    
    def create
      # create the svn repo
      Svn.create_project(self)
    
      # create the trac site
      Trac.create_project(self)
    
      # create the apache configuration
      Apache.create_project(self)
    end
    
    def archive
      # create a holding folder in temp
      project_tmp_dir = File.join(Config.tmp_dir,"#{full_name}")
      File.create_if_missing(project_tmp_dir)
      # move the subversion files
      FileUtils.cp_r(@svn_dir,File.join(project_tmp_dir,"svn"))
      # move the trac files
      FileUtils.cp_r(@trac_dir,File.join(project_tmp_dir,"trac"))
      gzip = File.join(Config.tmp_dir,"#{full_name}.tar.gz")
      `cd #{Config.tmp_dir}; tar -czvf #{gzip} #{full_name}; rm -rf #{project_tmp_dir}`
      puts "We've moved the project here: #{gzip}"
    end
    
    def delete
      #FileUtils.rm(project_tmp_dir)
      confirm = agree("Are you sure you want to delete? I can't undo this....[Y/n]")
      if confirm
        `rm -rf #{@svn_dir} #{@trac_dir}`
      end
    end

    private

      def full_name
         "#{@client.path}_#{@path}"      
      end

      def prepare_template(template)
        @template = File.join(File.dirname(__FILE__), "project", template)
        unless File.exists?(@template)
          # attempt download of remote template
          template_location = "file://#{Config.svn_dir}/templates/#{template}/trunk"
          @template = File.join(Config.tmp_dir,template)
          `svn export #{template_location} #{@template} --quiet --username #{Config.data[:admin_user]} --password #{Config.data[:admin_pass]}`
          # replace the tokens in the project
          glob_path, exp_search, exp_replace = "#{@template}/**","", @display_name
          # puts "Lets see what the filter has returned: #{Dir.glob(glob_path)}"
          Dir.glob(glob_path).each do |file|
            unless File.directory?(file) # only mess with files
              buffer = tokenize(File.new(file,'r').read)
              puts buffer
              File.open(file,'w') {|fw| fw.write(buffer)}
            end
          end
          # TODO: We'll need to run through and do some renaming if necessary
        end

			end

      # Replaces some tokens
      def tokenize( string )
        string.gsub( /\$\{project.display_name\}/, @display_name ).
               gsub( /\$\{client.display_name\}/, @client.display_name )
      end

  end

end
