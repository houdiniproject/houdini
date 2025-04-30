class JournalEntriesToItem < ApplicationRecord
  attr_accessible :item
  belongs_to :e_tap_import_journal_entry
  belongs_to :item, polymorphic: true
end
