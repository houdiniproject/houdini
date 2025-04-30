# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
# require 'insert/insert_donation'
# require 'timespan'
# require 'delayed_job_helper'

module PayRecurringDonation
  # Pay ALL recurring donations that are currently due; each payment gets a queued delayed_job
  # Returns the number of queued jobs
  def self.pay_all_due_with_stripe
    # Bulk insert the delayed jobs with a single expression
    ids = Psql.execute_vectors(
      QueryRecurringDonations._all_that_are_due
    )[1..-1].flatten

    jobs = ids.map do |id|
      {handler: DelayedJobHelper.create_handler(PayRecurringDonation, :with_stripe, [id])}
    end

    Psql.execute(Qexpr.new.insert(:delayed_jobs, jobs, {
      common_data: {
        run_at: Time.current,
        attempts: 0,
        failed_at: nil,
        last_error: nil,
        locked_at: nil,
        locked_by: nil,
        priority: 0,
        queue: "rec-don-payments"
      }
    }))
    ids
  end

  # run the payrecurring_donation in development so I can make sure we have the expected failures
  # def self._____test_do_not_use_pay_all_due_with_stripe
  #   # Bulk insert the delayed jobs with a single expression
  #   ids = Psql.execute_vectors(
  #       QueryRecurringDonations._all_that_are_due
  #   )[1..-1].flatten
  #
  #   output = ids.map{|id|
  #     begin
  #       i = PayRecurringDonation.with_stripe(id)
  #       result = {is_error:false, value: i}
  #     rescue => e
  #       result = {is_error: true, error_type: e.class.to_s, message: e.message, backtrace: e.backtrace}
  #     end
  #
  #     result
  #   }
  #
  #
  #
  #   return output
  # end

  # Charge an existing donation via stripe, only if it is due
  # Pass in an instance of an existing RecurringDonation
  def self.with_stripe(rd_id, force_run = false)
    ParamValidation.new({rd_id: rd_id}, {
      rd_id: {
        required: true,
        is_integer: true
      }
    })

    rd = RecurringDonation.includes(:misc_recurring_donation_info).where("id = ?", rd_id).first

    unless rd
      raise ParamValidation::ValidationError.new("#{rd_id} is not a valid recurring donation", {key: :rd_id})
    end

    return false if !force_run && !QueryRecurringDonations.is_due?(rd_id)

    donation = Donation.where("id = ?", rd["donation_id"]).first
    unless donation
      raise ParamValidation::ValidationError.new("#{rd["donation_id"]} is not a valid donation", {})
    end

    result = {}
    result = result.merge(InsertDonation.insert_charge({
      "card_id" => donation["card_id"],
      "recurring_donation" => true,
      "designation" => donation["designation"],
      "amount" => donation["amount"],
      "nonprofit_id" => donation["nonprofit_id"],
      "donation_id" => donation["id"],
      "supporter_id" => donation["supporter_id"],
      "old_donation" => true,
      "fee_covered" => rd.misc_recurring_donation_info&.fee_covered
    }))
    if result["charge"]["status"] != "failed"
      result["recurring_donation"] = Psql.execute(
        Qexpr.new.update(:recurring_donations, {n_failures: 0})
          .where("id=$id", id: rd_id).returning("*")
      ).first

      InlineJob::ModernObjectDonationStripeChargeJob.perform_later(donation: donation, legacy_payment: result["payment"])

      JobQueue.queue(JobTypes::DonationPaymentCreateJob, rd["donation_id"], result["payment"]["id"])
      InsertActivities.for_recurring_donations([result["payment"]["id"]])
    else
      result["recurring_donation"] = Psql.execute(
        Qexpr.new.update(:recurring_donations, {n_failures: rd["n_failures"] + 1})
          .where("id=$id", id: rd_id).returning("*")
      ).first
      DonationMailer.delay.donor_failed_recurring_donation(rd["donation_id"])
      rd.reload
      if rd["n_failures"] >= 3
        DonationMailer.delay.nonprofit_failed_recurring_donation(rd["donation_id"])
      end
      Supporter.find(donation["supporter_id"]).supporter_notes.create!(content: "This supporter had a payment failure for their recurring donation with ID #{rd_id}", user: User.find(540))
    end
    result
  end

  def self.fail_a_recurring_donation(rd, donation, notify_nonprofit = false)
    recurring_donation = Psql.execute(
      Qexpr.new.update(:recurring_donations, {n_failures: 3})
          .where("id=$id", id: rd["id"]).returning("*")
    ).first
    DonationMailer.delay.donor_failed_recurring_donation(rd["donation_id"])
    if notify_nonprofit
      DonationMailer.delay.nonprofit_failed_recurring_donation(rd["donation_id"])
    end
    Supporter.find(donation["supporter_id"]).supporter_notes.create!(content: "This supporter had a payment failure for their recurring donation with ID #{rd["id"]}", user: User.find(540))
    recurring_donation
  end
end
