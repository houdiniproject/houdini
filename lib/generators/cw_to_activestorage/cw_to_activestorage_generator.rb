# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class CwToActivestorageGenerator < Rails::Generators::Base
  source_root File.expand_path('templates', __dir__)

  def install_activestorage_tables
    rake 'active_storage:install'
  end
  
  def copy_uploaders
    if (!File.exists?('app/uploaders'))
      directory 'uploaders', 'app/uploaders'
    end
  end

  def include_uploaders
    file_and_search = [
      ["campaign.rb", "class Campaign < ApplicationRecord\n"],
      ["profile.rb", "class Profile < ApplicationRecord\n"],
      ['nonprofit.rb', "class Nonprofit < ApplicationRecord\n"],
      ['image_attachment.rb', "class ImageAttachment < ApplicationRecord\n"],
      ['event.rb', "class Event < ApplicationRecord\n"]
    ]
    file_and_search
      .select{|filename, _| !File.read("app/models/#{filename}").include?('###MIGRATION_FIELDS_BEGIN')}\
      .each do |filename, find_string|
        gsub_file("app/models/#{filename}",find_string ) do |match|
          match << File.read(Pathname(File.expand_path('templates', __dir__, )) + 'models' + "#{filename}")
      end  
    end
  end

  def create_column_migration_file
    if (Dir.glob("db/migrate/*_rename_uploader_columns.rb").none?)
      copy_file "migrate/rename_uploader_columns.rb", 
      "db/migrate/#{DateTime.now.strftime('%Y%m%d%H%M%S')}_rename_uploader_columns.rb"
    end
  end

  def add_carrierwave_gems
    gem "carrierwave", "~> 1"
    gem "carrierwave-aws"
  end
end
