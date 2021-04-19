# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
class AdminMailer < BaseMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.admin_mailer.notify_failed_gift.subject
  #
  def notify_failed_gift(donation, campaign_gift_option)
    @campaign_gift_option = campaign_gift_option
    @donation = donation
    mail subject: "Tried to associate donation #{donation.id} with campaign gift option #{campaign_gift_option.id} which is out of stock", to: Houdini.hoster.support_email, from: Houdini.hoster.support_email
  end
end
