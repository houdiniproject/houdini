# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "qx"

module UpdateActivities
  def self.for_supporter_notes(note)
    user_email = Qx.select("email")
      .from(:users)
      .where(id: note[:user_id])
      .execute
      .first["email"]

    Qx.update(:activities)
      .set(json_data: {content: note[:content], user_email: user_email}.to_json)
      .timestamps
      .where(attachment_id: note[:id])
      .execute
  end

  def self.for_one_time_donation(payment)
    activity = generate_for_one_time_donation(payment)
    activity.save! if activity
  end

  def self.generate_for_one_time_donation(payment)
    donation = payment.donation
    activity = payment.activities.first
    if activity
      activity.date = payment.date
      json_data = {
        gross_amount: payment.gross_amount,
        designation: donation.designation,
        dedication: donation.dedication
      }

      activity.json_data = json_data
      return activity
    end
    nil
  end
end
