module Subtrac
  module Commands
    class Delete
      def initialize(args, options)
        Subtrac.delete_project(options.project,options.client)
      end
    end
  end
end
