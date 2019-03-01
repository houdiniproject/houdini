# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module JobTypes
 class EmailJob
   def perform
    raise 'You need to override this'
   end

   def max_attempts
     MAX_EMAIL_JOB_ATTEMPTS || 1
   end

   def destroy_failed_jobs?
     false
   end

   def error(job, exception)
   end

   def reschedule_at(current_time, attempts)
     current_time + attempts**(2.195);
   end

   def queue_name
     'email_queue'
   end
 end
end