def all_ruby_files_in_directory(directory)
  ruby_file_paths = Dir[directory + '*.rb'] # Return array of ruby file paths

  ignore_files = [
    directory + 'transaction-manager-config-sample.rb'
  ]

  ruby_file_paths -= ignore_files

  return ruby_file_paths
end

def include_libraries
  libraries = [
    ['/lib/', ['transaction.rb']] # Current repo
  ]

  libraries.each do |library|
    directory = Dir.pwd + library[0] # Working directory + path to library

    # Include priority files
    if(library.size > 1)
      library[1].each do |priority_file_name|
        require_relative (directory + priority_file_name)
      end
    end

    # Include all other files
    all_ruby_files_in_directory(directory).each {|file| require file}
  end
end
