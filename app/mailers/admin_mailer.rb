class AdminMailer < BaseMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.admin_mailer.notify_failed_gift.subject
  #
  def notify_failed_gift(donation, campaign_gift_option)
    @campaign_gift_option = campaign_gift_option
    @donation = donation
    mail subject: "Tried to associate donation #{donation.id} with campaign gift option #{campaign_gift_option.id} which is out of stock", to: Settings.mailer.email, from: Settings.mailer.default_from
  end
end
