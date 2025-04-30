# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module QueryEmailSettings
  Settings = ["notify_payments", "notify_campaigns", "notify_events", "notify_payouts", "notify_recurring_donations"]

  def self.fetch(np_id, user_id)
    es = Psql.execute(%(
      SELECT *
      FROM email_settings
      WHERE nonprofit_id=#{Qexpr.quote(np_id.to_i)}
      AND user_id=#{Qexpr.quote(user_id.to_i)}
    )).first

    # If the user's event_settings table does not exist, return a hash with all settings true
    if es.nil?
      es = Psql.execute(%(
        SELECT column_name
        FROM information_schema.columns
        WHERE table_name='email_settings'
      )).map { |h| h["column_name"] }
        .reject { |name| ["id", "nonprofit_id", "user_id"].include?(name) }
        .each_with_object({}) { |name, h|
        h[name] = true
      }
    end
    es
  end
end
