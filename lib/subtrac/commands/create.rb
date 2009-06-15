module Subtrac
  module Commands
    class Create
      def initialize(args, options)
          Subtrac.create_project(options.project,options.client,options.template)
      end
    end
  end
end
