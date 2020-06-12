# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
class BillingSubscriptionMailer < BaseMailer
  def failed_notice(np_id)
    @nonprofit = Nonprofit.find(np_id)
    @billing_subscription = @nonprofit.billing_subscription
    @card = @nonprofit.active_card
    @billing_plan = @billing_subscription.billing_plan
    @emails = QueryUsers.all_nonprofit_user_emails(@nonprofit.id)
    mail(to: @emails, subject: "Action Needed, Please Update Your #{Houdini.general.name} Account")
  end
end
