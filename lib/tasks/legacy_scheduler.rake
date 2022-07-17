desc "This task is deprecated and serve only as an alias for cron_job_runner"

# This task exists only for legacy reasons, use cron_job_runner to run ScheduledJobs instead

task :heroku_scheduled_job, [:name] => :environment do |_t, args|
    job_name = args[:name]
    Rake::Task["cron_job_runner"].invoke(job_name)
end