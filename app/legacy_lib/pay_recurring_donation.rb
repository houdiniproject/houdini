# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE

require "timespan"

module PayRecurringDonation
  # Pay ALL recurring donations that are currently due; each payment gets a queued delayed_job
  # Returns the number of queued jobs
  def self.pay_all_due_with_stripe
    # Bulk insert the delayed jobs with a single expression
    ids = Psql.execute_vectors(
      QueryRecurringDonations._all_that_are_due
    )[1..-1].flatten

    PayRecurringDonationsJob.perform_later(*id)
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
  def self.with_stripe(rd_id)
    ParamValidation.new({rd_id: rd_id},
      rd_id: {
        required: true,
        is_integer: true
      })

    rd = RecurringDonation.where("id = ?", rd_id).first

    unless rd
      raise ParamValidation::ValidationError.new("#{rd_id} is not a valid recurring donation", key: :rd_id)
    end

    return false unless QueryRecurringDonations.is_due?(rd_id)

    donation = Donation.where("id = ?", rd["donation_id"]).first
    unless donation
      raise ParamValidation::ValidationError.new("#{rd["donation_id"]} is not a valid donation", {})
    end

    trx = nonprofit.transactions.build(amount: donation["amount"])
    result = {}
    result = result.merge(InsertDonation.insert_charge(
      "card_id" => donation["card_id"],
      "recurring_donation" => true,
      "designation" => donation["designation"],
      "amount" => donation["amount"],
      "nonprofit_id" => donation["nonprofit_id"],
      "donation_id" => donation["id"],
      "supporter_id" => donation["supporter_id"],
      "old_donation" => true
    ))
    if result["charge"]["status"] != "failed"
      rd.update(n_failures: 0)
      result["recurring_donation"] = rd

      Houdini.event_publisher.announce(:recurring_donation_payment_succeeded, donation, donation&.supporter&.locale || "en")

      donation = trx.donations.build(amount: donation["amount"], designation: donation["designation"], dedication: donation["dedication"], legacy_donation: donation)
      stripe_t = trx.build_subtransaction(
        subtransactable: StripeTransaction.new(amount: data["amount"]),
        payments: [
          SubtransactionPayment.new(
            paymentable: StripeCharge.new(payment: Payment.find(result["payment"]["id"]))
          )
        ],
        created: data["date"]
      )
      trx.save!
      donation.save!
      stripe_t.save!
      stripe_t.payments.each(&:publish_created)
      stripe_t.publish_created
      donation.publish_created
      trx.publish_created
      InsertActivities.for_recurring_donations([result["payment"]["id"]])
    else

      rd.n_failures += 1
      rd.save!
      result["recurring_donation"] = rd
      Houdini.event_publisher.announce(:recurring_donation_payment_failed, donation)
      InsertSupporterNotes.create({supporter: Supporter.find(donation["supporter_id"]), user: User.find(540), content: "This supporter had a payment failure for their recurring donation with ID #{rd_id}"})
    end
    result
  end

  def self.fail_a_recurring_donation(rd, donation, notify_nonprofit = false)
    recurring_donation = Psql.execute(
      Qexpr.new.update(:recurring_donations, n_failures: 3)
          .where("id=$id", id: rd["id"]).returning("*")
    ).first
    FailedRecurringDonationPaymentDonorEmailJob.perform_later Donation.find(rd["donation_id"])
    if notify_nonprofit
      FailedRecurringDonationPaymentNonprofitEmailJob.perform_later Donation.find(rd["donation_id"])
    end
    InsertSupporterNotes.create([{content: "This supporter had a payment failure for their recurring donation with ID #{rd["id"]}", supporter_id: donation["supporter_id"], user_id: 540}])
    recurring_donation
  end

  # Charge an existing donation via stripe, NO MATTER WHAT
  # Pass in an instance of an existing RecurringDonation
  def self.with_stripe_BUT_NO_MATTER_WHAT(rd_id, enter_todays_date, run_this = false, set_this_true = false, this_one_needs_to_be_false = true, is_this_run_dangerously = "no")
    if PayRecurringDonation::ULTIMATE_VERIFICATION(enter_todays_date, run_this, set_this_true, this_one_needs_to_be_false, is_this_run_dangerously)
      rd = Psql.execute("SELECT * FROM recurring_donations WHERE id=#{rd_id}").first
      donation = Psql.execute("SELECT * FROM donations WHERE id=#{rd["donation_id"]}").first

      result = {}
      result = result.merge(InsertDonation.insert_charge(
        "card_id" => donation["card_id"],
        "recurring_donation" => true,
        "designation" => donation["designation"],
        "amount" => donation["amount"],
        "nonprofit_id" => donation["nonprofit_id"],
        "donation_id" => donation["id"],
        "supporter_id" => donation["supporter_id"]
      ))
      if result["charge"]["status"] != "failed"
        result["recurring_donation"] = Psql.execute(
          Qexpr.new.update(:recurring_donations, n_failures: 0)
              .where("id=$id", id: rd_id).returning("*")
        ).first
        ## add PaymentNotificationJobHere
        InsertActivities.for_recurring_donations([result["payment"]["id"]])
      else
        result["recurring_donation"] = Psql.execute(
          Qexpr.new.update(:recurring_donations, n_failures: rd["n_failures"] + 1)
              .where("id=$id", id: rd_id).returning("*")
        ).first
        FailedRecurringDonationPaymentDonorEmailJob.perform_later Donation.find(rd["donation_id"])
        if rd["n_failures"] >= 3
          FailedRecurringDonationPaymentNonprofitEmailJob.perform_later Donation.find(rd["donation_id"])
        end
        InsertSupporterNotes.create([{content: "This supporter had a payment failure for their recurring donation with ID #{rd_id}", supporter_id: donation["supporter_id"], user_id: 540}])
      end
      return result
    end
    false
  end

  def self.ULTIMATE_VERIFICATION(enter_todays_date, run_this = false, set_this_true = false, this_one_needs_to_be_false = true, is_this_run_dangerously = "no")
    Date.parse(enter_todays_date) == Date.today && run_this && set_this_true && !this_one_needs_to_be_false && is_this_run_dangerously == "run dangerously"
  end
end
