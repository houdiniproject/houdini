# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE

desc "Task used to run any ScheduledJob"

# We use a single rake call so we can catch and send any errors that happen in the job
task :cron_job_runner, [:name] => :environment do |_t, args|
  job_name = args[:name]
  # Fetch all the super admin emails so we can send a report
  enum = ScheduledJobs.send(job_name)

  results = ""
  enum.each do |lamb|
    result = lamb.call
    results += "Success: #{result}\n"
  rescue Exception => e
    results += "Failure: #{e}\n"
  end

  GenericMailer.admin_notice(
    subject: "Scheduled job results on #{Houdini.hoster.casual_name} for '#{job_name}'",
    body: results.empty? ? "No jobs to run today." : results
  ).deliver_later
end
