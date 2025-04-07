# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class NonprofitAdminMailer < BaseMailer
  def new_invite(role, raw_token)
    @user = role.user
    @title_with_article = Format::Indefinitize.with_article(role.name.to_s.titleize)
    @nonprofit = role.host
    @token = raw_token
    mail(to: @user.email, subject: "You're now #{@title_with_article} of #{@nonprofit.name} on #{Houdini.general.name}. Let's set your password.")
  end

  def existing_invite(role)
    @user = role.user
    @title_with_article = Format::Indefinitize.with_article(role.name.to_s.titleize)
    @nonprofit = role.host
    mail(to: @user.email, subject: "You're now #{@title_with_article} of #{@nonprofit.name} on #{Houdini.general.name}.")
  end

  def supporter_fundraiser(event_or_campaign)
    @fundraiser = event_or_campaign
    @kind = event_or_campaign.class.name.downcase || "event"
    @nonprofit = event_or_campaign.nonprofit
    @profile = event_or_campaign.profile
    recipients = @nonprofit.nonprofit_personnel_emails
    mail(to: recipients, subject: "A Supporter has created #{Format::Indefinitize.with_article(@kind.capitalize)} for your Nonprofit!")
  end
end
