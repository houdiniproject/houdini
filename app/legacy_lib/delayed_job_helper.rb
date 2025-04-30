# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "qx"
require "delayed_job"

module DelayedJobHelper
  # Create a serialized delayed job handler for use in inserting new delayed jobs with raw sql
  # Be sure to wrap the handler in double quotes when inserting, not single
  def self.create_handler(obj, method_name, args)
    Delayed::PerformableMethod.new(obj, method_name, args).to_yaml.to_s
  end

  # Manually enqueue a job
  def self.enqueue_job(obj, method_name, args, options = {})
    handler = Delayed::PerformableMethod.new(obj, method_name, args).to_yaml.to_s
    Qx.insert_into(:delayed_jobs)
      .values({
        created_at: Time.current,
        updated_at: Time.current,
        priority: options[:priority] || 0,
        attempts: 0,
        handler: handler,
        run_at: options[:run_at] || Time.current,
        queue: options[:queue]
      }).returning("*").execute
  end
end
