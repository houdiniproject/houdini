# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class Recurrence < ApplicationRecord # rubocop:disable Metrics/ClassLength
  include Model::Houidable
  include Model::Jbuilder
  include Model::Eventable

  after_initialize :set_start_date_if_needed

  belongs_to :recurring_donation
  belongs_to :supporter

  has_one :nonprofit, through: :supporter

  delegate :currency, to: :nonprofit

  delegate :designation, :dedication, to: :recurring_donation

  validates :recurrences, presence: true

  def trx_assignments
    [{
      assignment_object: "donation",
      amount: amount || 0,
      dedication: dedication,
      designation: designation
    }.with_indifferent_access]
  end

  def recurrences
    [
      {
        interval: recurring_donation.interval,
        type: from_recurring_time_unit_to_recurrence(recurring_donation.time_unit),
        start: recurrence_start_date
      }
    ]
  end

  def invoice_template
    {
      amount: amount || 0,
      trx_assignments: trx_assignments,
      supporter: supporter,
      payment_method: {type: "stripe"}
    }
  end

  concerning :JBuilder do # rubocop:disable Metrics/BlockLength
    included do
      setup_houid :recur
    end

    def to_builder(*expand)	# rubocop:disable Metrics/MethodLength,Metrics/AbcSize,Metrics/CyclomaticComplexity
      init_builder(*expand) do |json|	# rubocop:disable Metrics/BlockLength
        json.start_date start_date.to_i

        json.add_builder_expansion :nonprofit, :supporter

        json.recurrences recurrences do |rec|
          json.call(rec, :interval, :type)
          json.start rec[:start].to_i
        end

        json.invoice_template do # rubocop:disable Metrics/BlockLength
          json.amount do
            json.cents amount || 0
            json.currency currency
          end

          json.supporter supporter.id

          json.payment_method do
            json.type "stripe"
          end

          json.trx_assignments trx_assignments do |assign|
            json.assignment_object assign[:assignment_object]
            dedication = assign[:dedication]

            if dedication
              json.dedication do
                json.type dedication["type"]
                json.name dedication["name"]
                contact = dedication["contact"]
                json.note dedication["note"]
                if contact
                  json.contact do
                    json.email contact["email"] if contact["email"]
                    json.address contact["address"] if contact["address"]
                    json.phone contact["phone"] if contact["phone"]
                  end
                end
              end
            end

            json.designation assign[:designation]

            json.amount do
              json.cents assign[:amount] || 0
              json.currency currency
            end
          end
        end
      end
    end

    def publish_created
      Houdini.event_publisher.announce(
        :recurrence_created,
        to_event("recurrence.created", :nonprofit, :trx, :supporter).attributes!
      )
    end

    def publish_updated
      Houdini.event_publisher.announce(
        :recurrence_updated,
        to_event("recurrence.updated", :nonprofit, :trx, :supporter).attributes!
      )
    end
  end

  private

  def set_start_date_if_needed
    self[:start_date] = Time.current unless self[:start_date]
  end

  def from_recurring_time_unit_to_recurrence(time_unit)
    {
      "month" => "monthly",
      "year" => "yearly"
    }[time_unit]
  end

  def recurrence_start_date # rubocop:disable Metrics/AbcSize
    paydate = recurring_donation.paydate
    paydate = if paydate.nil?
      (1..28).cover?(start_date.day) ? start_date.day : 28
    else
      paydate
    end
    if paydate < start_date.day
      (start_date + 1.month).beginning_of_month + (paydate - 1).days
    else
      start_date.beginning_of_month + (paydate - 1).days
    end
  end
end
