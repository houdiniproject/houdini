# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
# from https://coderwall.com/p/ijr6jq/rake-progress-bar
class ProgressBar
  attr_reader :total, :counter
  def initialize(total, description)
    @description = description
    @total = total
    @counter = 1
  end

  def increment
    print_out
    @counter += 1
  end

  def print_out
    complete = sprintf("%#.2f%%", ((@counter.to_f / @total.to_f) * 100))
    print "\r\e[0K#{@description} #{@counter}/#{@total} (#{complete})"
  end

  def increment_total(by_amount)
    @total += by_amount
    print_out
  end
end

namespace :houdini_upgrade do
  Rake::Task["install:migrations"].clear_comments
  desc <<~RUBY
    Run houdini upgrade to v2
    DESC:
      This task automates some of the process of upgrading to Houdini v2. It does
      the following:
      * installs and runs database migrations
      * migrates images from Carrierwave on AWS to your default ActiveStorage service
    
    USAGE: bin/rails houdini_upgrade:run[aws_bucket,aws_region]
    
    TASK ARGUMENTS:
      aws_bucket (required): the name of your AWS bucket where all your carrierwave images are hosted
      aws_region (required): AWS region of your AWS bucket. Carrierwave won't work
        without it.
      aws_assethost: protocol and domain where your AWS bucket contents can be 
        accessed. For example, this could be through Cloudfront
      shorter_test: a testing only argument which cuts down the number of images we copy
  RUBY
  task :run, [:aws_bucket, :aws_region, :aws_assethost, :shorter_test] do |t, args|
    if args[:aws_bucket].blank? || args[:aws_region].blank?
      puts "You must set aws_bucket and aws_region for houdini_upgrade:run like:"
      puts "  houdini_upgrade:run[aws_bucket,aws_region]"
      puts ""
      puts "See the full task description by running `bin/rails -D` or "
      puts "visit `docs/houdini_upgrade.md`"
    else
      Rake::Task["houdini_upgrade:install:migrations"].invoke
      sh "rails active_storage:install"
      Rake::Task["houdini_upgrade:cw_to_activestorage"].invoke(*args)
      sh "bundle"
      Rake::Task["db:migrate"].invoke
      migrate_upload_command = "rails houdini_upgrade:migrate_uploads"
      if args[:shorter_test]
        migrate_upload_command += "[true]"
      end
      sh migrate_upload_command
      Rake::Task["houdini_upgrade:create_backup_uploader_migration"].invoke
      sh "rails db:migrate"
      Rake::Task["houdini_upgrade:cleanup_upgrade_files"].invoke
      sh "bundle"
    end
  end

  task :cw_to_activestorage, [:aws_bucket, :aws_region, :aws_assethost] do |t, args|
    tail = ["--aws-bucket=#{args[:aws_bucket]}", "--aws-region=#{args[:aws_region]}"]

    tail.push("--aws-assethost=#{args[:aws_assethost]}") if args[:aws_assethost]
    sh "rails generate cw_to_activestorage #{tail.join(" ")}"
  end

  desc "Migrate your CarrierWave uploads to activestorage"
  task :migrate_uploads, [:shorter_test] => [:environment] do |t, args|
    progress_bar = ProgressBar.new(0, "Upload migration progress")
    results = []
    Rails.application.eager_load!
    # find activerecord descendents
    HoudiniUpgrade::UPLOADERS_TO_MIGRATE.each do |table|
      klass = table.class_name.constantize
      items_to_migrate = klass.where(table.fields.map { |i| i.migrated_name + " IS NOT NULL" }.join(" OR "))
      if args[:shorter_test]
        items_to_migrate = items_to_migrate.limit(10)
      end
      progress_bar.increment_total(items_to_migrate.count * table.fields.count)
      items_to_migrate
        .find_each do |record|
          table.fields.each do |field|
            if record.send(field.migrated_name + "?")
              results << process(upload_url: record.send(field.migrated_name).url.gsub(/\/#{field.migrated_name}\//, "/#{field.name}/"), attachment_name: field.name, record: record)
            end
            progress_bar.increment
          end
        end
    end

    copied = results.select { |i| i[:success] }.map { |i| i[:value] }
    errors = results.select { |i| !i[:success] }.map { |i| i[:value] }

    CSV.open("#{DateTime.now.utc.strftime("%Y%m%d%H%M%S")}_copied.csv", "wb") do |csv|
      csv << ["Class Name", "Id", "UploaderName", "FileToOpen"]
      copied.each { |row| csv << row }
    end

    CSV.open("#{DateTime.now.utc.strftime("%Y%m%d%H%M%S")}_errored.csv", "wb") do |csv|
      csv << ["Class Name", "Id", "UploaderName", "FileToOpen", "Error"]
      errors.each { |row| csv << row }
    end

    puts "Copied: #{copied.count}"
    puts "Errored: #{errors.count}"
  end

  def process(**args)
    file_to_open = nil
    begin
      if args[:upload_url]
        filename = File.basename(URI.parse(args[:upload_url]).to_s)
        file_to_open = args[:upload_url].start_with?("/") ? "." + args[:upload_url] : args[:upload_url]

        if !args[:simulate]
          attachment_relation = args[:record].send("#{args[:attachment_name]}")
          attachment_relation.attach(io: open(file_to_open), filename: filename)
        end
        return {success: true, value: [args[:record].class.name, args[:record].id, args[:attachment_name], file_to_open]}
      end
      nil
    rescue => e
      {success: false, value: [args[:record].class.name, args[:record].id, args[:attachment_name], file_to_open, e]}
    end
  end

  task :create_backup_uploader_migration do
    if Dir.glob("db/migrate/*_backup_uploader_columns.houdini_upgrade.rb").none?
      FileUtils.cp __dir__ + "/templates/backup_uploader_columns.rb",
        "db/migrate/#{(DateTime.now.utc + 1.second).strftime("%Y%m%d%H%M%S")}_backup_uploader_columns.houdini_upgrade.rb"
    end
  end

  task :delete_uploader_backup_tables_migration do
    if Dir.glob("db/migrate/*_backup_uploader_columns.houdini_upgrade.rb").none?
      FileUtils.cp __dir + "/templates/delete_uploader_backup_tables.rb",
        "db/migrate/#{(DateTime.now.utc + 1.second).strftime("%Y%m%d%H%M%S")}_delete_uploader_backup_tables.houdini_upgrade.rb"
    end
  end

  task :cleanup_upgrade_files do
    FileUtils.rm_r "app/uploaders" if File.exist?("app/uploaders")
    FileUtils.rm "config/initializers/carrierwave.rb" if File.exist?("config/initializers/carrierwave.rb")
    gemfile_lines = File.readlines("Gemfile").select { |i| !i.include?("gem 'carrierwave'") && !i.include?("gem 'carrierwave-aws'") }
    File.write("Gemfile", gemfile_lines.join)
    cleanup_model_files
  end

  def cleanup_model_files
    filename_roots = HoudiniUpgrade::UPLOADERS_TO_MIGRATE.map { |i| i.name.singularize }
    filename_roots.each do |f|
      filename = "app/models/#{f}.rb"
      file_contents = File.read(filename)
      file_contents = file_contents.sub(/\n\#\#\#MIGRATION_FIELDS_BEGIN(.*)\#\#\#MIGRATION_FIELDS_END/mx, "")
      File.write(filename, file_contents)
    end
  end
end
