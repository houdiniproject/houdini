# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
# require 'qx'
# require 'required_keys'
# require 'open-uri'
# require 'csv'
# require 'insert/insert_supporter'
# require 'insert/insert_full_contact_infos'
# require 'insert/insert_custom_field_joins'
# require 'insert/insert_tag_joins'

module InsertImport
  # Wrap the import in a transaction and email any errors
  def self.from_csv_safe(data)
    Qx.transaction do
      InsertImport.from_csv(data)
    end
  rescue Exception => e
    body = "Import failed. Error: #{e}"
    GenericMailer.generic_mail(
      "support@commitchange.com", "Jay Bot", # FROM
      body,
      "Import error", # SUBJECT
      "support@commitchange.com", "Jay" # TO
    ).deliver
  end

  # Insert a bunch of Supporter and related data using a CSV and a bunch of header_matches
  # See also supporters/import/index.es6 for the front-end piece that generates header_matches
  # This is a slow function; it is to be delayed-jobbed
  # data: nonprofit_id, user_email, user_id, file, header_matches
  # Will send a notification email to user_email when the import is completed
  def self.from_csv(data)
    ParamValidation.new(data, {
      file_uri: {required: true},
      header_matches: {required: true},
      nonprofit_id: {required: true, is_integer: true},
      user_email: {required: true}
    })

    nonprofit = Nonprofit.find(data[:nonprofit_id])

    import = Qx.insert_into(:imports)
      .values({
        date: Time.current,
        nonprofit_id: data[:nonprofit_id],
        user_id: data[:user_id]
      })
      .timestamps
      .returning("*")
      .execute.first
    row_count = 0
    imported_count = 0
    supporter_ids = []
    created_payment_ids = []

    # no spaces are allowed by open(). We could URI.encode, but spaces seem to be the only problem and we want to avoid double-encoding a URL
    data[:file_uri] = data[:file_uri].gsub(/ /, "%20")
    CSV.new(open(data[:file_uri]), headers: :first_row).each do |row|
      row_count += 1
      # triplet of [header_name, value, import_key]
      matches = row.map { |key, val| [key, val, data[:header_matches][key]] }
      next if matches.empty?
      table_data = matches.each_with_object({}) do |triplet, acc|
        key, val, match = triplet
        if match == "custom_field"
          acc["custom_fields"] ||= []
          acc["custom_fields"].push([key, val])
        elsif match == "tag"
          acc["tags"] ||= []
          acc["tags"].push(val)
        else
          table, col = match.split(".") if match.present?
          if table.present? && col.present?
            acc[table] ||= {}
            acc[table][col] = val
          end
        end
      end

      # Create supporter record
      if table_data["supporter"]
        table_data["supporter"] = nonprofit.supporters.create(
          table_data["supporter"],
          imported_at: Time.current,
          import: Import.find(import["id"])
        )
        supporter_ids.push(table_data["supporter"]["id"])
        imported_count += 1
      else
        table_data["supporter"] = {}
      end

      # Create custom fields
      if table_data["supporter"]["id"] && table_data["custom_fields"] && table_data["custom_fields"].any?
        InsertCustomFieldJoins.find_or_create(data[:nonprofit_id], [table_data["supporter"]["id"]], table_data["custom_fields"])
      end

      # Create new tags
      if table_data["supporter"]["id"] && table_data["tags"] && table_data["tags"].any?
        # Split tags by semicolons
        tags = table_data["tags"].select { |t| t.present? }.map { |t| t.split(/[;,]/).map(&:strip) }.flatten
        InsertTagJoins.find_or_create(data[:nonprofit_id], [table_data["supporter"]["id"]], tags)
      end

      # Create donation record
      if table_data["donation"] && table_data["donation"]["amount"] # must have amount. donation.date without donation.amount is no good
        amount_string = table_data["donation"]["amount"].gsub(/[^\d\.]/, "")
        table_data["donation"]["amount"] = (BigDecimal(amount_string.blank? ? 0 : amount_string) * 100).to_i
        table_data["donation"]["supporter_id"] = table_data["supporter"]["id"]
        table_data["donation"]["nonprofit_id"] = data[:nonprofit_id]
        table_data["donation"]["date"] = Chronic.parse(table_data["donation"]["date"]) if table_data["donation"]["date"].present?
        table_data["donation"]["date"] ||= Time.current
        table_data["donation"] = Qx.insert_into(:donations).values(table_data["donation"]).ts.returning("*").execute.first
        imported_count += 1
      else
        table_data["donation"] = {}
      end

      # Create payment record
      if table_data["donation"] && table_data["donation"]["id"]
        table_data["payment"] = Qx.insert_into(:payments).values({
          gross_amount: table_data["donation"]["amount"],
          fee_total: 0,
          net_amount: table_data["donation"]["amount"],
          kind: "OffsitePayment",
          nonprofit_id: data[:nonprofit_id],
          supporter_id: table_data["supporter"]["id"],
          donation_id: table_data["donation"]["id"],
          towards: table_data["donation"]["designation"],
          date: table_data["donation"]["date"]
        }).ts.returning("*")
          .execute.first
        imported_count += 1
      else
        table_data["payment"] = {}
      end

      # Create offsite payment record
      if table_data["donation"] && table_data["donation"]["id"]
        table_data["offsite_payment"] = Qx.insert_into(:offsite_payments).values({
          gross_amount: table_data["donation"]["amount"],
          check_number: GetData.chain(table_data["offsite_payment"], "check_number"),
          kind: (table_data["offsite_payment"] && table_data["offsite_payment"]["check_number"]) ? "check" : "",
          nonprofit_id: data[:nonprofit_id],
          supporter_id: table_data["supporter"]["id"],
          donation_id: table_data["donation"]["id"],
          payment_id: table_data["payment"]["id"],
          date: table_data["donation"]["date"]
        }).ts.returning("*")
          .execute.first
        imported_count += 1
      else
        table_data["offsite_payment"] = {}
      end

      created_payment_ids.push(table_data["payment"]["id"]) if table_data["payment"] && table_data["payment"]["id"]
    end

    # Create donation activity records
    InsertActivities.for_offsite_donations(created_payment_ids) if created_payment_ids.count > 0

    import = Qx.update(:imports)
      .set(row_count: row_count, imported_count: imported_count)
      .where(id: import["id"])
      .returning("*")
      .execute.first

    ImportMailer.delay.import_completed_notification(import["id"])
    import
  end
end
