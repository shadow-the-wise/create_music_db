require "pry"
require "json"

# methods {{{

# Git add lib/data/language/*
# Git commit -m "ADDED DATASET #{MODEL NAME}"
def get_dataset_directory(directory_location)
  raise ArgumentError, "Argument must be a String" unless directory_location.class == String
  Dir.glob(directory_location + "/**/*").select { |f| File.file? f }
end

def blue(color)
  "\e[34m#{color}\e[0m"
end

def red(color)
  "\e[31m#{color}\e[0m"
end

# }}}

namespace :gitdata do
  desc "Run on initial git init. It will add each data directory to git. Individualy."
  task add_to_git: :environment do
    # Home directory
    root = ENV["HOME"]

    # String
    # Type: String < Object
    #
    # Description:
    # Rails Application Root name.
    #
    app_name = Rails.application.class.module_parent.to_s

    # String
    # Type: String < Object
    #
    # Description:
    # Absolute path to the DATA directory.
    #
    data_directory = "#{root}/Code/Ruby/Projects/#{app_name}/lib/generators/create_music_db/templates/data"

    # Array
    # Type: Array < Object
    #
    # Description:
    # Get the DATA filepaths.
    #
    datasets = get_dataset_directory(data_directory)

    # Hash
    # Type: Hash < Oject
    #
    # Description:
    # Hash to store the information.
    #
    data_struct = {}

    # Array
    # Type: Array < Object
    #
    # Description:
    # Get the paths and separate at the data directory
    #
    datasets.each do |data|
      # Array
      # Type: Array < Object
      #
      # Description:
      # Split the filepath.
      #
      filepath = data.split("/")

      # Remove the last item.
      filepath.pop

      # Join the path back together.
      fp = filepath.join("/")

      # Get the end element of the path (the directory).
      data_root = File.basename(fp, File.extname(fp))


      # Hash
      # Type: Hash < Object
      #
      # Description:
      # The Hash has Value Arrays.
      # Add the end element as the Key and the full path with the filename
      # removed.
      #
      (data_struct[data_root] ||= []) << fp
    end

    # Hash
    # Type: Hash < Object
    #
    # Description:
    # Add each data directory to github and commit.
    # Rescue is used to avoid stoping the iterator if there is an error.
    #
    data_struct.each do |data, path|
      sh "git add #{path[0]}/*"
      sh "git commit -m \"added #{data}\""
    rescue StandardError => e
      puts red("ERROR OCCURED: Ln #{__LINE__} of #{__FILE__}")
      puts red("MSG: #{e.inspect}")
    end
  end
end
