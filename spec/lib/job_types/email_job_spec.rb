# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

describe JobTypes::EmailJob do
  describe ".reschedule_at" do
    it "50 attempts takes about 24 hours" do
      job = JobTypes::EmailJob.new
      initial_time = Time.utc(2020, 5, 5)
      end_time = initial_time + 1.day
      current_time = initial_time
      50.times.map { |i| i + 1 }.each { |i|
        current_time = job.reschedule_at(current_time, i)
      }
      expect(current_time).to be_between(end_time - 5.minutes, end_time + 5.minutes)
    end
  end
end
