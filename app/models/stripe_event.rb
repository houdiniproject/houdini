# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class StripeEvent < ActiveRecord::Base
  attr_accessible :event_id, :event_time, :object_id


  def self.handle(event)
    case event.type
    when 'account.updated'
      StripeEvent.transaction do
        object = event.data.object
        events_for_object_id = StripeEvent.where('object_id = ?', object.id).lock(true)

        event_record = events_for_object_id.where('event_id = ?', event.id).first

        # if event_record found, we've recorded this event so no processing necessary
        unless event_record
          # we record this event!
          stripe_event = StripeEvent.new(event_id: event.id, event_time: Time.at(event.created).to_datetime, object_id: event.data.object.id)
          stripe_event.save!

          later_event = events_for_object_id.where('event_time > ?', Time.at(event.created).to_datetime).first

          # we have a later event so we don't need to process this anymore
          unless later_event

            stripe_accounts = StripeAccount.where("stripe_account_id = ?", object.id).lock(true)

            account = stripe_accounts.first
            unless account
              account = StripeAccount.new
            end

            account.object = object
            account.save!
          end
        end
      end
    end
  end
end
