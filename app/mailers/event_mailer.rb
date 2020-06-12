# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
class EventMailer < BaseMailer
  helper :application

  include Devise::Controllers::UrlHelpers

  def creation_followup(event)
    @creator_profile = event.profile
    @event = event
    mail(to: @creator_profile.user.email, subject: "Get your new event rolling on #{Houdini.general.name}!")
  end
end
