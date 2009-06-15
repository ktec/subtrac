module Subtrac

  class Client

    attr_reader :display_name, :path

    def initialize(name)
      @display_name = name.gsub(/^[a-z]|\s+[a-z]/) { |a| a.upcase }
      @path = name.downcase.gsub(' ','_')
    end

  end

end
