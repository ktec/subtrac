module Subtrac
  module Commands
    class CreateTemplate
      def initialize(args, options)
        options.project = ask("What is the name of the template project you would like to create? ") if options.project.nil?
        options.client = "templates"
        Subtrac.create_project(options.project,options.client,"template")
      end
    end
  end
end
