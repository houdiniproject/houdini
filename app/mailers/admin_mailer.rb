# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class AdminMailer < BaseMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.admin_mailer.notify_failed_gift.subject
  #
  def notify_failed_gift(donation, payment, campaign_gift_option)
    @campaign_gift_option = campaign_gift_option
    @donation = donation
    @payment = payment
    mail subject: "Tried to associate donation #{donation.id} with campaign gift option #{campaign_gift_option.id} which is out of stock", to: Settings.mailer.email, from: Settings.mailer.default_from
  end
end
