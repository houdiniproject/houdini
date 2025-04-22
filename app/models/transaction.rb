# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class Transaction < ApplicationRecord
  include Model::CreatedTimeable

  belongs_to :supporter
  has_one :nonprofit, through: :supporter

  has_many :transaction_assignments, inverse_of: "trx"

  has_many :donations, through: :transaction_assignments, source: :assignable, source_type: "ModernDonation", inverse_of: "trx"
  has_many :ticket_purchases, through: :transaction_assignments, source: :assignable, source_type: "TicketPurchase", inverse_of: "trx"
  has_many :campaign_gift_purchases, through: :transaction_assignments, source: :assignable, source_type: "CampaignGiftPurchase", inverse_of: "trx"

  has_one :subtransaction
  has_many :payments, through: :subtransaction

  validates :supporter, presence: true

  def amount_as_money
    Amount.new(amount || 0, nonprofit.currency)
  end

  concerning :JBuilder do
    include Model::Houidable
    include Model::Jbuilder
    include Model::Eventable

    included do
      setup_houid :trx
    end

    def to_builder(*expand)
      init_builder(*expand) do |json|
        json.amount do
          json.cents amount || 0
          json.currency nonprofit.currency
        end
        json.created created.to_i

        json.add_builder_expansion :nonprofit, :supporter, :subtransaction
        json.add_builder_expansion :payments, enum_type: :expandable
        json.add_builder_expansion :transaction_assignments, enum_type: :expandable
      end
    end
  end

  concerning :ObjectEvents do
    include JBuilder
    def publish_created
      Houdini.event_publisher.announce(:transaction_created,
        to_event("transaction.created", :nonprofit, :supporter, :payments, :transaction_assignments, :subtransaction).attributes!)
    end

    def publish_updated
      Houdini.event_publisher.announce(:transaction_updated,
        to_event("transaction.updated", :nonprofit, :supporter, :payments, :transaction_assignments, :subtransaction).attributes!)
    end

    def publish_refunded
      Houdini.event_publisher.announce(:transaction_refunded,
        to_event("transaction.refunded", :nonprofit, :supporter, :payments, :transaction_assignments, :subtransaction).attributes!)
    end

    def publish_disputed
      Houdini.event_publisher.announce(:transaction_disputed,
        to_event("transaction.refunded", :nonprofit, :supporter, :payments, :transaction_assignments).attributes!)
    end

    def publish_deleted
      Houdini.event_publisher.announce(:transaction_deleted,
        to_event("transaction.deleted", :nonprofit, :supporter, :payments, :transaction_assignments).attributes!)
    end
  end

  private

  def set_created_if_needed
    self[:created] = Time.now unless self[:created]
  end
end

ActiveSupport.run_load_hooks(:houdini_transaction, Transaction)
