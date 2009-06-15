require 'subtrac/config'

module Subtrac

  class Template

    def initialize(template)
      @template = template
    end

    def render
      puts "Rendering template: #{File.basename(@template)}"
      b = Config.get_binding
      ERB.new(IO.read(@template)).result(b)
    end

    def write(outfile)
      file = File.open(outfile, 'w+')
      if file
        file_output = render()
        file.syswrite(file_output)
        puts("Template written: #{File.basename(outfile)}")
      else
        raise "Unable to open file for writing. file #{outfile}"
      end
    end

  end

end
