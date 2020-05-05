# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
# from https://coderwall.com/p/ijr6jq/rake-progress-bar
class ProgressBar
  attr_reader :total, :counter
  def initialize(total, description)
    @description  = description
    @total   = total
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
  desc "Run houdini upgrade to v2"
  task :run, [:aws_bucket, :aws_region, :aws_assethost] do |t, args|
    Rake::Task["houdini_upgrade:install:migrations"].invoke
    Rake::Task["active_storage:install"].invoke
    Rake::Task["houdini_upgrade:cw_to_activestorage"].invoke(*args)
    sh 'bundle'
    Rake::Task["db:migrate"].invoke
    sh "rails houdini_upgrade:migrate_uploads"
    Rake::Task["houdini_upgrade:create_backup_uploader_migration"].invoke
    Rake::Task["db:migrate"].invoke

  end

  task :cw_to_activestorage, [:aws_bucket, :aws_region, :aws_assethost] do |t, args|
    tail = ["--aws-bucket=#{args[:aws_bucket]}", "--aws-region=#{args[:aws_region]}"]
    
    tail.push("--aws-assethost=#{args[:aws_assethost]}") if args[:aws_assethost]
    sh "rails generate cw_to_activestorage #{tail.join(' ')}"
  end

  desc "Migrate your CarrierWave uploads to activestorage"
  task :migrate_uploads, [:simulate, :write_out_to_files] => [:environment] do |t, args|
    progress_bar = ProgressBar.new(0, "Upload migration progress")
    results = []
    Rails.application.eager_load!
    # find activerecord descendents
    HoudiniUpgrade::UPLOADERS_TO_MIGRATE.each do |table|
      klass = table.class_name.constantize
      items_to_migrate = klass.where(table.fields.map{|i| i.migrated_name + " IS NOT NULL"}.join(" OR "))
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

    copied = results.select{|i| i[:success]}.map{|i| i[:value]}
    errors = results.select{|i| !i[:success]}.map{|i| i[:value]}
    if args.write_out_to_files
      CSV.open('copied.csv', 'wb') do |csv|
          csv << ['Name', 'Id', "UploaderName", "FileToOpen", "CodeToRun"]
          copied.each {|row| csv << row}
      end

      CSV.open('errored.csv', 'wb') do |csv|
          csv << ['Name', 'Id', "UploaderName", "Error"]
          errors.each {|row| csv << row}
      end
    end
    byebug
    puts "Copied: #{copied.count}"
    puts "Errored: #{errors.count}"
  end

  def process(**args)
    begin
      if args[:upload_url]
        filename = File.basename(URI.parse(args[:upload_url]).to_s)
        file_to_open = args[:upload_url].start_with?('/') ? "." + args[:upload_url] : args[:upload_url]
        
        if (!args[:simulate])
            attachment_relation = args[:record].send("#{args[:attachment_name].to_s}")
            attachment_relation.attach(io: open(file_to_open), filename: filename)
        end
        return {success: true, value: [args[:record].id,args[:attachment_name],file_to_open]}
      end
      return nil
    rescue => e
      return {success: false, value: [ args[:record].id, args[:attachment_name], e]}
    end
  end

  task :create_backup_uploader_migration do
    if (Dir.glob("db/migrate/*_backup_uploader_columns.rb").none?)
      FileUtils.cp __dir + "/templates/backup_uploader_columns.rb", 
      "db/migrate/#{(DateTime.now + 1.second).strftime('%Y%m%d%H%M%S')}_backup_uploader_columns.rb"
    end
  end

  task :delete_uploader_backup_tables_migration do
    if (Dir.glob("db/migrate/*_backup_uploader_columns.rb").none?)
      FileUtils.cp __dir + "/templates/delete_uploader_backup_tables.rb", 
      "db/migrate/#{(DateTime.now + 1.second).strftime('%Y%m%d%H%M%S')}_delete_uploader_backup_tables.rb"
    end
  end

  task :cleanup_upgrade_files do
    FileUtils.rm_r "app/uploaders"
    FileUtils.rm "config/initializers/carrierwave.rb"
    gemfile_lines = File.readlines("Gemfile").select{|i| !i.include?("gem 'carrierwave'") && !i.include?("gem 'carrierwave-aws'")}
    File.write('Gemfile', gemfile_lines.join("\n"))
    cleanup_model_files
  end

end
