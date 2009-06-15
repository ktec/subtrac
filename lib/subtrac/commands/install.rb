module Subtrac
  module Commands
    class Install
      def initialize(args, options)
        Subtrac.install(args,options)
      end
    end
  end
end
