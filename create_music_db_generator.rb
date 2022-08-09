class CreateMusicDbGenerator < Rails::Generators::Base
  source_root File.expand_path("templates", __dir__)

  # Copy the gitdata tasks to the tasks directory
  def add_git_task_file
    remove_file "lib/tasks/gitdata.rake"
    copy_file "gitdata.rake", "lib/tasks/gitdata.rake"
  end

  # Copy DATASET to lib/data
  def create_dataset
    directory "data_json", "lib/data_json"
  end

  # Copy the rake tasks for building the datasets to lib/tasks
  def create_music_task
    copy_file "music.rake", "lib/tasks/music.rake"
  end

  # TODO: change over the name data to data_json
  # NOTE: changed template/music and tasks/music
  # Rake the build models task.
  def run_dataset_rake_tasks
    rake "music:build_models"
  end

  # Create the seed file to add the dataset to the DB Models.
  def create_seed_file
    remove_file "db/seeds.rb"
    copy_file "seeds.rb", "db/seeds.rb"
  end

  # Create Artist Model for DATA ENTRY
  def create_data_entry_model_artist
    rake "music:create_artist"
  end

  # Create Album Model for DATA ENTRY
  def create_data_entry_model_album
    rake "music:create_album"
  end

  # Create Song Model for DATA ENTRY
  def create_data_entry_model_song
    rake "music:create_song"
  end

  # Migrate the dataset built by run_dataset_rake_tasks.
  def migrate_the_dataset
    rake "db:migrate"
  end

  # Add the datasets to the DB MODELS.
  def run_the_rake_seed_file
    rake "db:seed"
  end
end
