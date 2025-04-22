# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
# rubocop:disable Metrics/BlockLength, Metrics/AbcSize, Metrics/MethodLength
class OfflineTransaction < ApplicationRecord
  include Model::Subtransactable
  delegate :created, to: :subtransaction

  def amount_as_money
    Amount.new(amount || 0, nonprofit.currency)
  end

  def net_amount
    payments.sum(&:net_amount)
  end

  def net_amount_as_money
    Amount.new(net_amount || 0, nonprofit.currency)
  end

  concerning :JBuilder do
    included do
      setup_houid :offlinetrx
    end
    def to_builder(*expand)
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
        json.object "offline_transaction"
        json.type "subtransaction"
      end
    end

    def publish_created
      Houdini.event_publisher.announce(
        :offline_transaction_created,
        to_event("offline_transaction.created", :nonprofit, :trx, :supporter,
          :payments).attributes!
      )
    end
  end
end
# rubocop:enable all
