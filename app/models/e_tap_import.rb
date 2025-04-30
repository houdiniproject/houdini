class ETapImport < ApplicationRecord
  attr_accessible :nonprofit
  belongs_to :nonprofit
  has_many :e_tap_import_journal_entries do
    def create_from_csv(filename)
      CSV.read(filename, headers: true).each do |row|
        create(row: row.to_h)
      end
    end
  end
  has_many :e_tap_import_contacts do
    def create_from_csv(filename)
      CSV.read(filename, headers: true).each do |row|
        create(row: row.to_h)
      end
    end
  end
  has_many :reassignments

  def self.create_import(nonprofit, journal_file, contacts_file)
    transaction do
      e_tap_import = create(nonprofit: nonprofit)
      e_tap_import.e_tap_import_contacts.create_from_csv(contacts_file)
      e_tap_import.e_tap_import_journal_entries.create_from_csv(journal_file)
    end
  end

  def process(user)
    e_tap_import_journal_entries.order("e_tap_import_journal_entries.id ASC").each do |entry|
      transaction do
        if entry.unprocessed?
          entry.to_wrapper.process(user)
        end
      end
    end
  end
end
