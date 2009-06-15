

##
# Create directories if required

def File.create_if_missing *names
  names.each do |name| 
    unless File.directory?(name) 
      FileUtils.mkdir_p(name)
    end
  end 
end
