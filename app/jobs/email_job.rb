class EmailJob < ApplicationJob
  queue_as :email_queue

  retry_on Exception, wait: ->(executions) { executions**2.195 }, attempts: MAX_EMAIL_JOB_ATTEMPTS || 1
end
