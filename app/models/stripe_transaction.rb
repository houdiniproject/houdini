# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class StripeTransaction < ApplicationRecord
  include Model::Subtransactable
  delegate :created, to: :subtransaction

  def net_amount
    payments.sum(&:net_amount)
  end

  concerning :JBuilder do # rubocop:disable Metrics/BlockLength
    included do
      setup_houid :stripetrx
    end
    def to_builder(*expand) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      init_builder(*expand) do |json|
        json.type "subtransaction"
        json.created created.to_i
        json.initial_amount do
          json.cents amount || 0
          json.currency nonprofit.currency
        end

        json.net_amount do
          json.cents net_amount
          json.currency nonprofit.currency
        end

        if expand.include? :payments
          json.payments payments do |py|
            json.merge! py.to_builder.attributes!
          end
        else
          json.payments payments do |py|
            json.merge! py.to_id.attributes!
          end
        end

        json.add_builder_expansion :nonprofit, :supporter

        json.add_builder_expansion(
          :trx,
          json_attribute: :transaction
        )
      end
    end

    def to_id
      ::Jbuilder.new do |json|
        json.call(self, :id)
        json.object "stripe_transaction"
        json.type "subtransaction"
      end
    end

    def publish_created
      Houdini.event_publisher.announce(
        :stripe_transaction_created,
        to_event("stripe_transaction.created", :nonprofit, :trx, :supporter,
          :payments).attributes!
      )
    end
  end
end
