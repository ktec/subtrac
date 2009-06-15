module Subtrac
  module Commands
    class TracAdmin
      def initialize(args, options)
        # the rest is destined for each trac instance
        str = args.collect{|a| a + " "}.to_s.chop
        # now lets get the trac dirs
        Subtrac.trac_admin(str)
      end
    end
  end
end
