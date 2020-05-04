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
  task :run, [:aws_bucket, :aws_assethost]  => :environment do |t, args|
    Rake::Task["houdini_upgrade:install:migrations"].invoke
    Rake::Task["active_storage:install"].invoke
    Rake::Task["houdini_upgrade:cw_to_activestorage"].invoke(*args)
    Rake::Task["houdini_upgrade:migration"].invoke
  end

  task :migration do
    sh 'rails db:migrate'
  end

  task :cw_to_activestorage, [:aws_bucket, :aws_assethost] do |t, args|
    tail = ["--aws-bucket=#{args[:aws_bucket]}"]
    tail.push("--aws-assethost=#{args[:aws_assethost]}") if args[:aws_assethost]
    sh "rails generate cw_to_activestorage #{tail.join(' ')}"
  end
end
