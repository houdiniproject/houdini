# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module ImportCivicrmPayments
  ## MINIMALLY TESTED!!!
  def self.import_from_csv(csv_body, nonprofit, field_of_supporter_id)
    Qx.transaction do
      CSV::Converters[:blank_to_nil] = lambda do |field|
        (field && field.empty?) ? nil : field
      end

      csv = CSV.new(csv_body, headers: true, converters: [:blank_to_nil])
      contrib_records = csv.to_a.map { |row| row.to_hash }
      pay_imp = PaymentImport.create(nonprofit: nonprofit)

      supporter_id_custom_field = CustomFieldMaster.where("nonprofit_id = ? AND name = ?", nonprofit.id, field_of_supporter_id).first

      unless supporter_id_custom_field
        raise ParamValidation::ValidationError.new("There is no custom field for nonprofit #{nonprofit.id} and field named #{field_of_supporter_id}", {key: :field_of_supporter_id})
      end

      supporters_with_fields = Supporter.includes(:custom_field_joins).where("supporters.nonprofit_id = ? AND custom_field_joins.custom_field_master_id = ?", nonprofit.id, supporter_id_custom_field.id)
      questionable_records = []
      contrib_records.each { |r|
        our_supporter = supporters_with_fields.where("custom_field_joins.value = ?", r[field_of_supporter_id].to_s).first
        unless our_supporter
          questionable_records.push(r)
          next
        end

        known_fields = ["Date Received", "Total Amount"]

        notes = ""
        r.except(known_fields).keys.each { |k|
          notes += "#{k}: #{r[k]}\n"
        }

        offsite = nil
        if r["payment_instrument"] == "Check"
          offsite = {kind: "check", check_number: r["Check Number"]}
        end

        puts r["Date Received"]
        date_received = nil

        Time.use_zone("Pacific Time (US & Canada)") do
          date_received = Time.zone.parse(r["Date Received"])
          puts date_received
        end

        d = InsertDonation.offsite(
          {
            amount: Format::Currency.dollars_to_cents(r["Total Amount"]),
            nonprofit_id: nonprofit.id,
            supporter_id: our_supporter.id,
            comment: notes,
            date: date_received.to_s,
            offsite_payment: offsite
          }.with_indifferent_access
        )
        puts d
        pay_imp.donations.push(Donation.find(d[:json]["donation"]["id"]))
      }
      questionable_records
    end
  end

  def self.undo(import_id)
    Qx.transaction do
      import = PaymentImport.find(import_id)
      import.donations.each { |d|
        d.payments.each { |p|
          p.destroy
        }
        if d.offsite_payment
          d.offsite_payment.destroy
        end

        d.destroy
      }

      import.destroy
    end
  end
end
