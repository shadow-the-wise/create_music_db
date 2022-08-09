#!/usr/bin/env ruby

require "pry"
require "json"
require "logger"

# TODO: Error handling
# TODO: Logging
# TODO: Is there a preexisting DATASET
# TODO: find the key with the value before the build DATASET
# TODO: Validate keys are spelled correctly?
#

# Hash
# Type: Hash < Object
#
# Description:
# Hash that contains a record of the datasets that exists without a
# corrisponding model. This means the model/migration has eaither not been
# generated or not been raked.
#
rejected = {}

#------------------------------------------------------------------------------
# logger
#------------------------------------------------------------------------------

class String
  def camel_case
    return self if self !~ /_/ && self =~ /[A-Z]+.*/
    split("_").map { |e| e.capitalize }.join
  end
end

def blue(color)
  "\e[34m#{color}\e[0m"
end

def red(color)
  "\e[31m#{color}\e[0m"
end

# Logger
#
# Description:
# Create a Instance of Logger. log app status's
#
logger = Logger.new(STDOUT,
  level: Logger::INFO,
  progname: "Music",
  datetime_format: "%Y-%m-%d %H:%M:%S",
  formatter: proc do |severity, datetime, progname, msg|
    "[#{blue(progname)}][#{datetime}], #{severity}: #{msg}\n"
  end
)

# Log Info
logger.info("Music db Seeding...")

#------------------------------------------------------------------------------
# Files paths
#------------------------------------------------------------------------------

# Method
# Returns: Hash
#
# Parses Json files. Expects a Arg filepath.
#
def read_file_build_hash(data)
  begin
    data_hash = JSON.parse(File.read(data))
  rescue StandardError => e
    puts "ERROR OCCURRED: Ln: #{__LINE__} of #{__method__} in #{__dir__}"
    puts "LOCATION: #{data}" + "\n" + " #{red(e.inspect)}"
    exit
  end
  data_hash
end

# Method
# Type:
#
# Description:
# Creates and array of absolute filepaths.
#
def sub_dir(directory_location)
  Dir.glob(directory_location + "/**/*").select { |f| File.file? f }
end


# -----------------------------------------------------------------------------
# Setup
# -----------------------------------------------------------------------------

# String
#
# Description:
# Enviroment Variable for the home directory.
#
home = ENV["HOME"]

# String
# Type: String < Object
#
# Description:
# Rails application name from the root of the directory.
#
app_name = Rails.application.class.module_parent.to_s

# String
# Type: String < Object
#
# Description:
# Root dataset directory
#
root = "#{home}/Code/Ruby/Projects/#{app_name}/lib/data_json"


# String
# Type: String < Object
#
# Description:
# Root models directory
#
models = "#{home}/Code/Ruby/Projects/#{app_name}/app/models"
# -----------------------------------------------------------------------------
#   Create Filepaths
# -----------------------------------------------------------------------------

# Array
# Type: Array < Object
#
# Description:
# filepaths to each file.
#
filepaths = sub_dir(root)
modelpaths = sub_dir(models)

# Array
# Type: Array < Object
#
# Description:
# Create two Arrays to evaluate against each other
#
models_trim = modelpaths.map { |f| File.basename(f, File.extname(f)) }
data_trim = filepaths.map { |f| File.basename(f, File.extname(f)) }

# Array
# Type: Array < Object
#
# Description:
# Create two Arrays of just the end path name. Ie. The model name. Subtract all
# the created Models from the data_trim Array. And any left are models that
# have not been Migrated.
#
unmigrated_models = data_trim - models_trim

# compare the paths
#
logger.info("#{filepaths.count} files found in the filepath") if filepaths.present?

#------------------------------------------------------------------------------
#   Create Data Sets
#------------------------------------------------------------------------------

# Array
# Type: Array < Object
#
# Description:
# Iterate over the filepaths. Read the file and parse with JSON.
#
filepaths.each do |data_file|
  data = File.basename(data_file, File.extname(data_file))
  # A comparison of the two Arrays is done. The remainder is then used as a
  # validation. If no unmigrated_models exist the result will always be true.
  # If not the datasets that have no corrisponding models will be omitted and
  # added to the rejected list.
  #
  if unmigrated_models.include?(data)
    rejected[data] = data_file
  else

    # Hash
    # Type: Hash < Object
    #
    # Description:
    # Create Hash from read_file_build_hash Method
    #
    data_hash = read_file_build_hash(data_file)
    # ---------------------------------------------------------------------------
    #   Set Variables
    # ---------------------------------------------------------------------------

    # Split the file on the DATA DIR. Creating two Array items.
    #
    # [0] /Users/shadowchaser/Code/Ruby/Projects/lyric/lib/data
    # [1] /ALL DATASETS
    #
    # Remove Ext from path and split path
    #
    extention_removed = data_file.chomp(File.extname(data_file))

    # split path on the data directory and select the [1] index item.
    #
    structure = extention_removed.split("data_json")[1]
    data_keys = structure.split("/").reject(&:empty?)

    # ---------------------------------------------------------------------------
    # Get key depth
    # ---------------------------------------------------------------------------
    key_depth = data_keys.count

    # ---------------------------------------------------------------------------
    # Set Keys
    # ---------------------------------------------------------------------------

    # Set the keys to the value of the Array or empty string
    #
    first = data_keys[0] ||= ""
    second = data_keys[1] ||= ""
    third = data_keys[2] ||= ""
    fourth = data_keys[3] ||= ""

    # ---------------------------------------------------------------------------
    # Create Constant token
    # ---------------------------------------------------------------------------

    # Array gives a count but the index is from 0 so we have to correct for it.
    #
    offset = 1
    index = key_depth - offset
    final_key = data_keys[index]
    token = File.basename(final_key, File.extname(final_key))

    # ---------------------------------------------------------------------------
    #   Iterate Over The DATASET
    # ---------------------------------------------------------------------------

    # Array
    # Type: Array < Object
    #
    # Words
    # Iterate over the datafiles Dataset Array. Rescuse any StandardError and
    # Break the words loop to the next Dataset.
    #
    data_hash["Dataset"].each do |word|
      token.camel_case.constantize.find_or_create_by(
        word: word,
        primary: first,
        secondary: second,
        tertiary: third,
        quaternary: fourth,
      )
    end

    # If the last command returns nil do not print otherwise do.
    #
    if $CHILD_STATUS == nil
      logger.warn("a record already exists for #{data_file.split("/")[-1]}")
    else
      logger.info("creating data set for #{data_file.split("/")[-1]}")
    end
  end
end

# If there is no a dataset and corrisponding model. Tell the user.
#
if rejected.present?
  rejected.each { |k, v| logger.error(red("#{k}: #{v}")) }
end
