# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE

module HealthReport
  # Send an email report about what has happend on the servers and database in the last 24hrs, and how things are running
  # Returns a hash of metrics data
  def self.query_data
    # Transaction metrics
    charges = Qx.select("COUNT(charges.id), SUM(charges.amount), SUM(charges.fee) as fees")
      .from("charges")
      .where("created_at > $d", d: 24.hours.ago)
      .and_where("charges.status != 'failed'")
      .ex.last

    # Recurring donation metrics
    rec_dons = Qx.select("COUNT(id), SUM(amount)")
      .from("recurring_donations")
      .where("active=TRUE")
      .ex.last

    # Info about disabled nonprofit accounts due to ident verification
    disabled_nps = Qx.select("nonprofits.id", "nonprofits.name", "nonprofits.stripe_account_id")
      .from("nonprofits")
      .where("verification_status != 'verified'")
      .and_where("created_at > $d", d: 3.months.ago)
      .ex(format: "csv")

    {
      charges_count: charges["count"],
      charges_sum: charges["sum"],
      charges_fees: charges["fees"],
      recently_disabled_nps: disabled_nps,
      active_rec_don_count: rec_dons["count"],
      active_rec_don_amount: rec_dons["sum"]
    }
  end

  # Given a hash of data, formats it into a multi-line string
  def self.format_data(data)
    disabled_nps = Format::Csv.from_array(data[:recently_disabled_nps])

    %(
Transaction Metrics for the last 24hrs:
Total count: #{data[:charges_count]}
Total amount: $#{Format::Currency.cents_to_dollars(data[:charges_sum])}
Total fees processed: $#{Format::Currency.cents_to_dollars(data[:charges_fees])}

Active recurring donation metrics:
Total active count: #{data[:active_rec_don_count]}
Total active amount: $#{Format::Currency.cents_to_dollars(data[:active_rec_don_amount])}

Recent nonprofit accounts that are disabled due to identity verification:
#{disabled_nps}
)
  end
end
