#!/usr/bin/env ruby
require "pry"

# Creates and array of absolute filepaths.
def dataset_dir(directory_location)
  Dir.glob(directory_location + "/**/*").select { |f| File.file? f }
end

# Root data directory.
root = Rails.root.join("lib/data_json").to_s

namespace :music do
  desc "Build all DATASET MODELS Example: music:build_models"
  task build_models: :environment do
    # Array
    # Type: Array < Object
    #
    # Description:
    # Create an Array of filepaths from lib/data. Any nested Directory's files
    # will be added.
    #
    filepaths = dataset_dir(root)

    # Iterate over each Dataset
    #
    filepaths.each do |file|
      # Remove the file extension leaving just the end of the file name.
      #
      name = File.basename(file, File.extname(file))

      # Eager load the models.
      #
      Rails.application.eager_load!

      # Collect all the descendants of the Application Record Classes.
      #
      rails_models = ApplicationRecord.descendants.collect { |type| type.name }

      # Build Models
      #
      unless rails_models.include?(name.camelize)
        sh "rails g model #{name.camelize} word:string primary:string secondary:string tertiary:string quaternary:string --no-timestamps"
      end
    end
  end

  desc "Create Artist Model for DATA ENTRY. Example: music:create_artist"
  task create_artist: :environment do
    sh "rails g model Artist name:string --no-timestamps"
  end

  desc "Create Album Model for DATA ENTRY. Example: music:create_album"
  task create_album: :environment do
    sh "rails g model Album title:string artist:references --no-timestamps"
  end

  desc "Create Song Model for DATA ENTRY. Example: music:create_song"
  task create_song: :environment do
    sh "rails g model Song title:string author:string char_count:integer word_count:integer line_count:integer longest_syllable:integer sumtotal_syllables:integer reading_ease:float grade_level:float syllable_count:text syllable_percentage:text lyric_lines:text sentiment:text addional_sentiment:text lexicon:text album:references --no-timestamps"

    puts "\n"
    puts "---------------------------------------------------------------------"
    puts "Song Model Attribute Help"
    puts "---------------------------------------------------------------------"
    puts "Add Serializaton to the app/model/song.rb"
    puts "\n"
    puts "serialize :lyric_lines, Array"
    puts "serialize :syllable_percentage, Hash"
    puts "serialize :syllable_count, Hash"
    puts "serialize :sentiment, Hash"
    puts "serialize :addional_sentiment, Hash"
    puts "serialize :lexicon, Hash"
  end
end
