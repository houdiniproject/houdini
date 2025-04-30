# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class EventMailer < BaseMailer
  helper :application

  include Devise::Controllers::UrlHelpers

  def creation_followup(event)
    @creator_profile = event.profile
    @event = event
    mail(to: @creator_profile.user.email, subject: "Get your new event rolling on #{Settings.general.name}!")
  end
end
