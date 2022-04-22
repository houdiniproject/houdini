# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require 'hash'
module InsertCard
  # Create a new card
  # If a stripe_customer_id is present, then update that customer's primary source; otherwise create a new customer
  # @param [ActiveSupport::HashWithIndifferentAccess] card_data card data
  # @option card_data [Integer] holder_id the primary key of the card's holder
  # @option card_data [String] holder_type the type of the card holder. Must be 'Nonprofit' or 'Supporter'

  # @option card_data [String] stripe_card_token the card token from stripe
  # @option card_data [String] stripe_card_id the card id from stripe
  # @option card_data [String] name the card name
  # @option card_data [String] cardholder_name (nil) the name of the cardholder
  # @option card_data [String] stripe_customer_id (nil) the stripe customer id as provided by stripe

  # @param [String] stripe_account_id not clear what this should do.
  # @param [Integer] event_id id for events with when you want it associated with an event
  # @param [User] current_user the user making the request. Used for validating that the current_user can make a long term token request
  def self.with_stripe(card_data, _stripe_account_id = nil, event_id = nil, current_user = nil)
    begin
      ParamValidation.new(card_data.merge(event_id: event_id),
                          holder_type: { required: true, included_in: %w[Nonprofit Supporter] },
                          holder_id: { required: true },
                          stripe_card_id: { not_blank: true, required: true },
                          stripe_card_token: { not_blank: true, required: true },
                          name: { not_blank: true, required: true },
                          event_id: { is_reference: true })
    rescue ParamValidation::ValidationError => e
      raise e
    end

    # validate that the user is with the correct nonprofit

    card_data = card_data.slice(:holder_type, :holder_id, :stripe_card_id, :stripe_card_token, :name)
    holder_types = { 'Nonprofit' => :nonprofit, 'Supporter' => :supporter }
    holder_type = holder_types[card_data[:holder_type]]
    holder = nil
    begin
      if holder_type == :nonprofit
        holder = Nonprofit.select('id, email').includes(:cards).find(card_data[:holder_id])
      elsif holder_type == :supporter
        holder = Supporter.select('id, email, nonprofit_id').includes(:cards, :nonprofit).find(card_data[:holder_id])
      end
    rescue ActiveRecord::RecordNotFound
      raise 'Sorry, you need to provide a nonprofit or supporter'
    end

    begin
      if holder_type == :supporter && event_id
        event = Event.where('id = ?', event_id).first
        unless event
          raise ParamValidation::ValidationError.new("#{event_id} is not a valid event", key: :event_id)
        end

        if holder.nonprofit != event.nonprofit
          raise ParamValidation::ValidationError.new("Event #{event_id} is not for the same nonprofit as supporter #{holder.id}", key: :event_id)
        end

        unless QueryRoles.is_authorized_for_nonprofit?(current_user.id, holder.nonprofit.id)
          raise AuthenticationError
        end
      end
    rescue AuthenticationError => e
      raise e
    rescue StandardError => e
      raise "Oops! There was an error: #{e.message}"
    end
    stripe_account_hash = {} # stripe_account_id ? {stripe_account: stripe_account_id} : {}
    begin
      if card_data[:stripe_customer_id]
        stripe_customer = Stripe::Customer.retrieve(card_data[:stripe_customer_id], stripe_account_hash)

      else
        stripe_customer = Stripe::Customer.create(customer_data(holder, card_data), stripe_account_hash)
      end
      stripe_customer.sources.create(source: card_data[:stripe_card_token])

      card_data[:stripe_customer_id] = stripe_customer.id
    rescue Stripe::CardError => e
      raise "Oops! #{e.json_body[:error][:message]}"
    rescue Stripe::StripeError => e
      raise "Oops! There was an error processing your payment, and it did not complete. Please try again in a moment. Error: #{e}"
    end

    card = nil
    source_token = nil
    begin
      Card.transaction do
        if holder_type == :nonprofit
          # @type [Nonprofit] holder
          card = holder.create_active_card(card_data)
        elsif holder_type == :supporter
          # @type [Supporter] holder
          card = holder.cards.create(card_data)
          params = {}
          params[:event] = event if event
          source_token = InsertSourceToken.create_record(card, params)
        end
        card.save!
      end
    # rescue ActiveRecord::ActiveRecordError => e
    #   return { json: { error: "Oops! There was an error saving your card, and it did not complete. Please try again in a moment. Error: #{e}" }, status: :unprocessable_entity }
    rescue e
      raise "Oops! There was an error saving your card, and it did not complete. Please try again in a moment. Error: #{e}"
    end
    source_token
end

  def self.customer_data(holder, card_data)
    { email: holder['email'], metadata: { cardholders_name: card_data[:cardholders_name], holder_id: card_data[:holder_id], holder_type: card_data[:holder_type] } }
  end
end
