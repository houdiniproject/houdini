# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class CwToActivestorageGenerator < Rails::Generators::Base
  source_root File.expand_path("templates", __dir__)
  class_option :aws_bucket, type: :string, required: true
  class_option :aws_region, type: :string, required: false
  class_option :aws_assethost, type: :string, required: false

  def add_carrierwave_gems
    gem "carrierwave", "~> 1"
    gem "carrierwave-aws"
  end

  def copy_uploaders
    if !File.exist?("app/uploaders")
      directory "uploaders", "app/uploaders"
    end
  end

  def include_uploaders
    file_and_search = [
      ["campaign.rb", "class Campaign < ApplicationRecord"],
      ["profile.rb", "class Profile < ApplicationRecord"],
      ["nonprofit.rb", "class Nonprofit < ApplicationRecord"],
      ["image_attachment.rb", "class ImageAttachment < ApplicationRecord"],
      ["event.rb", "class Event < ApplicationRecord"]
    ]
    file_and_search
      .select { |filename, _| !File.read("app/models/#{filename}").include?("###MIGRATION_FIELDS_BEGIN") }
      .each do |filename, find_string|
      gsub_file("app/models/#{filename}", find_string) do |match|
        match << "\n"
        match << File.read(Pathname(File.expand_path("templates", __dir__)) + "models" + "#{filename}")
      end
    end
  end

  def create_column_migration_file
    if Dir.glob("db/migrate/*_rename_uploader_columns.houdini_upgrade.rb").none?
      copy_file "migrate/rename_uploader_columns.rb",
        "db/migrate/#{(DateTime.now.utc + 1.second).strftime("%Y%m%d%H%M%S")}_rename_uploader_columns.houdini_upgrade.rb"
    end
  end

  def add_carrierwave_template
    @aws_bucket = options[:aws_bucket]
    @aws_region = options[:aws_region]
    @aws_assethost = options[:aws_assethost] || "https://#{@aws_bucket}.s3.amazonaws.com"
    template "initializers/carrierwave.rb", "config/initializers/carrierwave.rb"
  end
end
