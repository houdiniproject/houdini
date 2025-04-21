# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class ImportRequest < ApplicationRecord
  belongs_to :nonprofit
  has_one_attached :import_file

  def execute_safe(user)
    ImportRequest.transaction do
      execute(user)
    end
  rescue Exception => e
    body = "Import failed. Error: #{e}"
    GenericMailer.generic_mail(
      Houdini.hoster.support_email, Houdini.hoster.support_email, # FROM
      body,
      "Import error", # SUBJECT
      Houdini.hoster.support_email, Houdini.hoster.support_email # TO
    ).deliver
  end

  def execute(user)
    import = Import.create(date: Time.current, nonprofit: nonprofit, user: user)

    row_count = 0
    imported_count = 0
    supporter_ids = []
    created_payment_ids = []

    import_file_blob.open do |file|
      CSV.new(file, headers: :first_row).each do |row|
        row_count += 1
        # triplet of [header_name, value, import_key]
        matches = row.map { |key, val| [key, val, header_matches[key]] }
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
          table_data["supporter"] = InsertSupporter.defaults(table_data["supporter"])
          table_data["supporter"]["imported_at"] = Time.current
          table_data["supporter"]["import_id"] = import["id"]
          table_data["supporter"]["nonprofit_id"] = nonprofit.id
          table_data["supporter"] = Qx.insert_into(:supporters).values(table_data["supporter"]).ts.returning("*").execute.first
          supporter_ids.push(table_data["supporter"]["id"])
          imported_count += 1
        else
          table_data["supporter"] = {}
        end

        # Create custom fields
        if table_data["supporter"]["id"] && table_data["custom_fields"] && table_data["custom_fields"].any?
          InsertCustomFieldJoins.find_or_create(nonprofit.id, [table_data["supporter"]["id"]], table_data["custom_fields"])
        end

        # Create new tags
        if table_data["supporter"]["id"] && table_data["tags"] && table_data["tags"].any?
          # Split tags by semicolons
          tags = table_data["tags"].select(&:present?).map { |t| t.split(/[;,]/).map(&:strip) }.flatten
          InsertTagJoins.find_or_create(nonprofit.id, [table_data["supporter"]["id"]], tags)
        end

        # Create donation record
        if table_data["donation"] && table_data["donation"]["amount"] # must have amount. donation.date without donation.amount is no good
          table_data["donation"]["amount"] = (table_data["donation"]["amount"].gsub(/[^\d\.]/, "").to_f * 100).to_i
          table_data["donation"]["supporter_id"] = table_data["supporter"]["id"]
          table_data["donation"]["nonprofit_id"] = nonprofit.id
          table_data["donation"]["date"] = Chronic.parse(table_data["donation"]["date"]) if table_data["donation"]["date"].present?
          table_data["donation"]["date"] ||= Time.current
          table_data["donation"] = Qx.insert_into(:donations).values(table_data["donation"]).ts.returning("*").execute.first
          imported_count += 1
        else
          table_data["donation"] = {}
        end

        # Create payment record
        if table_data["donation"] && table_data["donation"]["id"]
          table_data["payment"] = Qx.insert_into(:payments).values(
            gross_amount: table_data["donation"]["amount"],
            fee_total: 0,
            net_amount: table_data["donation"]["amount"],
            kind: "OffsitePayment",
            nonprofit_id: nonprofit.id,
            supporter_id: table_data["supporter"]["id"],
            donation_id: table_data["donation"]["id"],
            towards: table_data["donation"]["designation"],
            date: table_data["donation"]["date"]
          ).ts.returning("*")
            .execute.first
          imported_count += 1
        else
          table_data["payment"] = {}
        end

        # Create offsite payment record
        if table_data["donation"] && table_data["donation"]["id"]
          table_data["offsite_payment"] = Qx.insert_into(:offsite_payments).values(
            gross_amount: table_data["donation"]["amount"],
            check_number: table_data["offsite_payment"] && table_data["offsite_payment"]["check_number"],
            kind: (table_data["offsite_payment"] && table_data["offsite_payment"]["check_number"]) ? "check" : "",
            nonprofit_id: nonprofit.id,
            supporter_id: table_data["supporter"]["id"],
            donation_id: table_data["donation"]["id"],
            payment_id: table_data["payment"]["id"],
            date: table_data["donation"]["date"]
          ).ts.returning("*")
            .execute.first
          imported_count += 1
        else
          table_data["offsite_payment"] = {}
        end

        created_payment_ids.push(table_data["payment"]["id"]) if table_data["payment"] && table_data["payment"]["id"]
      end
    end

    # Create donation activity records
    InsertActivities.for_offsite_donations(created_payment_ids) if created_payment_ids.count > 0

    import.row_count = row_count
    import.imported_count = imported_count
    import.save!

    Supporter.where("supporters.id IN (?)", supporter_ids).each do |s|
      Houdini.event_publisher.announce(:supporter_create, s)
    end
    ImportCompletedJob.perform_later(import)
    destroy
    import
  end
end
