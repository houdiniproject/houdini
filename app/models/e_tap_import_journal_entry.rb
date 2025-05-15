class ETapImportJournalEntry < ApplicationRecord
  def self.by_account(account_id)
    where("row @> '{\"Account Number\": \"#{account_id}\"}'")
  end

  def e_tap_import_contact
    e_tap_import.e_tap_import_contacts.find_by_account_id(account_id)
  end

  def supporter_through_e_tap_import_contact
    e_tap_import_contact.supporter
  end

  def supporters_through_journal_entries
    journal_entries_to_items.map(&:item).map(&:supporter).uniq
  end

  def account_id
    row["Account Number"]
  end

  module Common
    module Payment
      def designation
        @row["Fund"]
      end

      def campaign
        @row["Campaign"]
      end

      def approach
        @row["Approach"]
      end

      def letter
        @row["Letter"]
      end

      def to_payment_note
        note_contents = []
        if campaign.present?
          note_contents += ["Campaign: #{campaign}"]
        end
        if approach.present?
          note_contents += ["Approach: #{approach}"]
        end

        if letter.present?
          note_contents += ["Letter: #{letter}"]
        end

        note_contents.join("  \n")
      end

      def corresponding_matches?
        corresponding_payment.gross_amount == amount
      end

      def create_or_update_payment
        # supporter = nil
        # got_via_address = false

        supporter = if corresponding_payment&.supporter
          @entry.contact.create_or_update_CUSTOM(corresponding_payment.supporter)
          # byebug if supporter.id == 2362354
          # #sync_contact_with_supporter
        else
          ## create new supporter
          @entry.contact.create_or_update_CUSTOM
          # byebug if supporter.id == 2362354
        end

        if corresponding_payment && corresponding_matches?
          unless corresponding_payment.tickets.any?
            byebug unless corresponding_payment.donation
            UpdateDonation.update_payment(corresponding_payment.donation.id, {
              designation: designation,
              campaign_id: "",
              event_id: ""
            }.merge(
              corresponding_payment&.donation&.comment ? {
                comment: corresponding_payment.donation.comment
              } : {}
            ).with_indifferent_access)
          end

          corresponding_payment
        else
          result = InsertDonation.offsite({
            supporter_id: supporter.id,
            nonprofit_id: @entry.e_tap_import.nonprofit.id,
            date: date.to_s,
            designation: designation,
            amount: amount
          }.with_indifferent_access.merge(methods.include?(:to_payment_note) ? {comment: to_payment_note} : {}))
          ::Payment.find(result[:json]["payment"]["id"])
        end
      end
    end

    module Pledge
      def pledged
        @row["Pledged"]
      end

      def pledge_written_off
        @row["Pledge Written Off?"]
      end
    end

    module Purchase
      def authorization_code
        gift_type_info["Authorization Code"]
      end

      def corresponding_payment
        if authorization_code.to_i != 0
          begin
            @corresponding_payment ||= @np.payments.find(authorization_code.to_i)
          rescue
            @corresponding_payment ||= nil
          end
        else
          @corresponding_payment ||= nil
        end
      end

      def amount
        @row["Received"].gsub(/(\D|\.)/, "").to_i
      end

      def gift_type_info
        @row["Gift Type Information"].split(",").map(&:strip).map { |i| i.split(":").map(&:strip) }.map { |row|
          if row.count == 1
            [row[0], nil]
          elsif row.count > 2
            [row[0], nil]
          else
            row
          end
        }.to_h
      end
    end
  end

  attr_accessible :row
  has_many :journal_entries_to_items

  # has_many :items, through: :journal_entries_to_items, source: :item
  belongs_to :e_tap_import

  scope :processed, -> { joins(:journal_entries_to_items) }
  # scope :unprocessed, -> {includes(:journal_entries_to_items).where("journal_entries_to_items.id = null").references(:journal_entries_to_items)}

  def unprocessed?
    journal_entries_to_items.none?
  end

  def to_wrapper
    case type
    when "Note"
      NoteRow.new self
    when "Contact"
      ContactEvent.new self
    when "Calendar Item"
      CalendarItem.new self
    when "Gift"
      Gift.new self
    when "Payment"
      CreditPurchase.new self
    when "Pledge"
      Pledge.new self
    when "Pledge / Payment"
      PledgePayment.new self
    end
  end

  def self.find_all_by_contact(contact)
    id = contact.is_a?(ETapImportContact) ? contact.account_id : contact
    where("row->>? = ?", "Account Number", id)
  end

  def type
    row["Type"]
  end

  def contact
    e_tap_import.e_tap_import_contacts.find_by_account_id(row["Account Number"])
  end

  class RowWrapper
    attr_accessor :entry
    def initialize(entry)
      @row = entry.row
      @entry = entry
    end

    def date
      month, day, year = @row["Date"].split("/")
      @date ||= ActiveSupport::TimeZone["Central Time (US & Canada)"].local(year, month, day)
    end

    def supporter
      entry.e_tap_import.nonprofit.supporters.not_deleted.includes(custom_field_joins: :custom_field_master).where("custom_field_masters.name = ? AND custom_field_joins.value = ?", "E-Tapestry Id #", contact.id.to_s).references(:custom_field_masters, :custom_field_joins).first
    end

    def contact
      @entry.contact
    end

    def find_or_create_supporter
      supporter || contact.create_or_update_CUSTOM
    end
  end

  class NoteRow < RowWrapper
    def note
      @note ||= @row["Note"]
    end

    def to_supporter_note
      {created_at: date, content: note}
    end

    def process(user)
      sn = find_or_create_supporter.supporter_notes.build(user: user, **to_supporter_note.except(:created_at))

      sn.created_at = to_supporter_note[:created_at]
      sn.save!
      @entry.journal_entries_to_items.create(item: sn)
    end
  end

  class ContactEvent < RowWrapper
    def note
      @note ||= @row["Note"]
    end

    def subject
      @row["Contact Subject"]
    end

    def to_supporter_note
      {created_at: date, content: "Subject: #{subject}, Note: #{note}"}
    end

    def process(user)
      sn = find_or_create_supporter.supporter_notes.build(user: user, **to_supporter_note.except(:created_at))

      sn.created_at = to_supporter_note[:created_at]
      sn.save!
      @entry.journal_entries_to_items.create(item: sn)
    end
  end

  class CalendarItem < RowWrapper
    def to_supporter_note
      {created_at: date, content: "Calendar Item"}
    end

    def process(user)
      sn = find_or_create_supporter.supporter_notes.build(user: user, **to_supporter_note.except(:created_at))

      sn.created_at = to_supporter_note[:created_at]
      sn.save!
      @entry.journal_entries_to_items.create(item: sn)
    end
  end

  class Gift < RowWrapper
    include ::ETapImportJournalEntry::Common::Payment
    include ::ETapImportJournalEntry::Common::Purchase
    def corresponding_payment
      nil
    end

    def process(user)
      @entry.journal_entries_to_items.create(item: create_or_update_payment)
    end
  end

  class Pledge < RowWrapper
    include ::ETapImportJournalEntry::Common::Pledge

    def to_supporter_note
      content = "Pledged: #{pledged}"
      if pledge_written_off.present?
        content += "\nPledge Written Off? #{pledge_written_off}"
      end
      {created_at: date, content: content}
    end

    def process(user)
      sn = find_or_create_supporter.supporter_notes.build(user: user, **to_supporter_note.except(:created_at))

      sn.created_at = to_supporter_note[:created_at]
      sn.save!
      @entry.journal_entries_to_items.create(item: sn)
    end
  end

  class CreditPurchase < RowWrapper
    include Common::Purchase
    include Common::Payment

    def process(user)
      @entry.journal_entries_to_items.create(item: create_or_update_payment)
    end
  end

  class PledgePayment < RowWrapper
    include Common::Purchase
    include Common::Payment
    include Common::Pledge

    def to_supporter_note
      content = "Pledged: #{pledged}"
      if pledge_written_off.present?
        content += "\nPledged Written Off? #{pledge_written_off}"
      end
      {created_at: date, content: content}
    end

    def process(user)
      je_to_i = @entry.journal_entries_to_items.create(item: create_or_update_payment)
      sn = je_to_i.item.supporter.supporter_notes.build(user: user, **to_supporter_note.except(:created_at))

      sn.created_at = to_supporter_note[:created_at]
      sn.save!
      @entry.journal_entries_to_items.create(item: sn)
    end
  end
end
