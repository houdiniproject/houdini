class ETapImportContact < ApplicationRecord
  attr_accessible :row, :nonprofit
  belongs_to :e_tap_import
  has_one :nonprofit, through: :e_tap_import

  def supporters
    nonprofit.supporters.not_deleted.includes(custom_field_joins: :custom_field_master)
      .where("custom_field_masters.name = ?", "E-Tapestry Id #")
      .where("custom_field_joins.value = ?", account_id.to_s).references(:custom_field_joins, :custom_field_masters)
  end

  def supporter
    supporters.first
  end

  def self.with_supporters
    select { |i| !i.supporter.nil? }
  end

  def self.without_supporters
    select { |i| i.supporter.nil? }
  end

  def self.matched_by_address
    cfm = CustomFieldMaster.find_by_name("Got Supporter by address")

    select { |i| i.supporter&.custom_field_joins&.select { |i| i.custom_field_master_id == cfm.id }&.any? }
  end

  def self.find_by_account_id(account_id)
    where("row @> '{\"Account Number\": \"#{account_id}\"}'").first
  end

  def journal_entries
    e_tap_import.e_tap_import_journal_entries.by_account(row["Account Number"])
  end

  def self.find_by_account_name(account_name, account_email, original_account_id)
    query = where("row @> '{\"Account Name\": \"#{account_name}\"}' OR row @> '{\"Email\": \"#{account_email}\"}' OR row @> '{\"Email Address 2\": \"#{account_email}\"}' OR row @> '{\"Email Address 3\": \"#{account_email}\"}'")
    if account_email.blank?
      query = where("row @> '{\"Account Name\": \"#{account_name}\"}'")
    end
    query.where("NOT row @> '{\"Account Number\": \"#{original_account_id}\"}'").first
  end

  def create_or_update_CUSTOM(known_supporter = nil)
    custom_fields_to_save = to_custom_fields
    latest_journal_entry = journal_entries.first

    supporter = known_supporter ||
      self.supporter ||
      e_tap_import.nonprofit.supporters.not_deleted.where("name = ? AND LOWER(COALESCE(email, '')) = ?", name, email&.downcase).first

    if !supporter && !(address.blank? && state.blank? && city.blank?)
      supporter = e_tap_import.nonprofit.supporters.not_deleted.where("name = ? AND address = ? AND state_code = ? AND city = ?", name, address, state, city).first
      if supporter.present?
        custom_fields_to_save += [["Got Supporter by address", "#{name}, #{address}, #{state}, #{city}"]]
        true
      end
    end

    # is this also relate to the latest payment
    if supporter
      if (latest_journal_entry&.to_wrapper&.date || Time.at(0)) >= (supporter.payments.order("date DESC").first&.date || Time.at(0))
        puts "update the supporter info"
        begin
          # did we overwrite the email?
          if supporter.persisted? && supporter.email && to_supporter_args[:email] && supporter.email.downcase != to_supporter_args[:email].downcase
            cfj = supporter.custom_field_joins.joins(:custom_field_master).where("custom_field_masters.name = ?", "Overwrote previous email").references(:custom_field_masters).first
            val = (cfj&.split(",") || []) + [supporter.email]
            custom_fields_to_save += [["Overwrote previous email", val.join(",")]]
          end
          supporter.update(to_supporter_args)
        rescue PG::NotNullViolation => e
          byebug
          raise e
        end
      else
        puts "do nothing!"
      end
    else
      supporter = e_tap_import.nonprofit.supporters.create(to_supporter_args)
    end

    InsertCustomFieldJoins.find_or_create(e_tap_import.nonprofit.id, [supporter.id], custom_fields_to_save) if custom_fields_to_save.any?
    supporter
  end

  def journal_entries
    e_tap_import.e_tap_import_journal_entries.find_all_by_contact(self)
  end

  def name
    row["Account Name"] || ""
  end

  def account_id
    row["Account Number"]
  end

  def organization
    row["Company"]
  end

  def address
    row["Parsed Address"] || ""
  end

  def city
    row["Parsed City"] || ""
  end

  def zip_code
    row["Parsed ZIP Code"] || ""
  end

  def state
    row["Parsed State"] || ""
  end

  def country
    row["Parsed Country"] || ""
  end

  def email
    if emails.count > 0
      emails[0]
    end
  end

  def email_address2
    if emails.count > 1
      emails[1]
    end
  end

  def email_address3
    if emails.count > 2
      emails[2]
    end
  end

  def full_address
    row["Full Address with Country (Single Line)"] || ""
  end

  def church_parish
    row["County"]
  end

  def created_at
    row["Creation Date"]
  end

  def created_by
    row["Created By"]
  end

  def envelope_salutation
    row["Envelope Salutation"]
  end

  def supporter_phone
    if phone_numbers.count > 0
      phone_numbers[0]
    end
  end

  def supporter_phone_2
    if phone_numbers.count > 1
      phone_numbers[1]
    end
  end

  def supporter_phone_3
    if phone_numbers.count > 2
      phone_numbers[2]
    end
  end

  def to_supporter_args
    supporter_args = {
      email: email,
      name: name,
      organization: organization,
      address: address,
      city: city,
      state_code: state,
      country: country,
      zip_code: zip_code
    }

    unless supporter_phone.nil?
      supporter_args = supporter_args.merge(phone: supporter_phone)
    end

    supporter_args
  end

  def to_custom_fields
    custom_fields = [["E-Tapestry Id #", account_id]]
    if supporter_phone_2
      custom_fields += [["Supporter Phone 2", supporter_phone_2]]
    end

    if supporter_phone_3
      custom_fields += [["Supporter Phone 3", supporter_phone_3]]
    end

    if email_address2
      custom_fields += [["Email Address 2", email_address2]]
    end

    if email_address3
      custom_fields += [["Email Address 3", email_address3]]
    end

    if church_parish
      custom_fields += [["Church Parish", church_parish]]
    end

    if envelope_salutation
      custom_fields += [["Envelope Salutation", envelope_salutation]]
    end

    if created_at
      custom_fields += [["Created At", created_at]]
    end

    if created_by
      custom_fields += [["Created By", created_by]]
    end

    custom_fields
  end

  def emails
    [row["Email Address 1"], row["Email Address 2"], row["Email Address 3"]].select { |i| i.present? }
  end

  private

  def phone_numbers
    [row["Phone - Voice"], row["Phone - Mobile"], row["Phone - Cell"]].select { |i| i.present? }
  end
end
