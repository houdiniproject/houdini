# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later

desc "For use with Heroku's Scheduler add-on"

# We use a single rake call so we can catch and send any errors that happen in the job
task :heroku_scheduled_job, [:name] => :environment do |t, args|
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
  GenericMailer.delay.admin_notice({
    subject: "Scheduled job results on CommitChange for '#{job_name}'",
    body: results.empty? ? "No jobs to run today." : results
  })
end
