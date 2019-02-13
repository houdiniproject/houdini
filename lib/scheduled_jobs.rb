# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'qx'
require 'enumerator'

module ScheduledJobs

  # Each of these functions should return an Enumerator
  # Each value in the enumerator should be a lambda
  # That way the heroku_scheduled_job task can iterate over each lambda
  # and wrap each call in begin/rescue/end blocks
  # and it can continue to execute all the parts of the job without bailing early, even if one part of the job fails
  # And it will aggregate success/failure messages from all the lambdas in the enum

  # Clear out all junk tables. Warning, some of this is dangerous yo!
  def self.delete_junk_data
    # Delete all custom fields with emptly/nil vals
    del_cfjs_noval = Qx.delete_from(:custom_field_joins)
      .where("value IS NULL OR value=''")
    # Delete orphaned custom field joins (those should also all have supporters)
    del_cfjs_orphaned = Qx.delete_from(:custom_field_joins).where("id IN ($ids)", {
      ids: Qx.select("custom_field_joins.id")
        .from(:custom_field_joins)
        .left_join("supporters", "custom_field_joins.supporter_id=supporters.id")
        .where("supporters.id IS NULL")
    })
    # Delete orphaned tag joins
    del_tags_orphaned = Qx.delete_from(:tag_joins).where("id IN ($ids)", {
     ids: Qx.select("tag_joins.id")
        .from(:tag_joins)
        .left_join(:supporters, "tag_joins.supporter_id=supporters.id")
        .where("supporters.id IS NULL")
    })

    return Enumerator.new do |yielder|
      yielder << lambda do
        del_cfjs_noval.execute
        "Successfully cleaned up custom field joins with no values"
      end
      yielder << lambda do
        del_cfjs_orphaned.execute
        "Successfully cleaned up custom field joins that have been orphaned from supporters"
      end
      yielder << lambda do
        del_tags_orphaned.execute
        "Successfully cleaned up tags that have been orphaned from supporters"
      end
    end
  end


  def self.pay_recurring_donations
    return Enumerator.new do |yielder|
      yielder << lambda do
        ids = PayRecurringDonation.pay_all_due_with_stripe
        "Queued jobs to pay #{ids.count} total recurring donations\n Recurring Donation Ids to run are: \n#{ids.join('\n')}"
      end
    end
  end

  def self.update_verification_statuses
    return Enumerator.new do |yielder|
      Nonprofit.where(verification_status: 'pending').each do |np|
        yielder << lambda do
          acct = Stripe::Account.retrieve(np.stripe_account_id)
          verified = acct.transfers_enabled && acct.verification.fields_needed.count == 0
          np.verification_status = verified ? 'verified' : np.verification_status
          NonprofitMailer.failed_verification_notice(np).deliver if np.verification_status != 'verified'
          NonprofitMailer.successful_verification_notice(np).deliver if np.verification_status == 'verified'
          np.save
          "Status updated for NP #{np.id} as '#{np.verification_status}'"
        end
      end
    end
  end

  def self.update_np_balances
    return Enumerator.new do |yielder|
      nps = Nonprofit.where("id IN (?)", Charge.pending.uniq.pluck(:nonprofit_id))
      nps.each do |np|
        yielder << lambda do
          UpdateNonprofit.mark_available_charges(np.id)
          "Updated charge statuses for NP #{np.id}"
        end
      end
    end
  end

  def self.update_pending_payouts
    return Enumerator.new do |yielder|
      Payout.pending.includes(:nonprofit).each do |p|
        yielder << lambda do
          err = false
          p.status = Stripe::Transfer.retrieve(p.stripe_transfer_id, {
            stripe_account: p.nonprofit.stripe_account_id
          }).status
          p.save
          "Updated status for NP #{p.nonprofit.id}, payout # #{p.id}"
        end
      end
    end
  end

  def self.delete_expired_source_tokens
    return Enumerator.new do |yielder|
      yielder << lambda do
        tokens_deleted = SourceToken.where("expiration > ?", DateTime.now - 1.day).delete_all
        "Deleted #{tokens_deleted} source tokens"
      end
    end
  end
end
