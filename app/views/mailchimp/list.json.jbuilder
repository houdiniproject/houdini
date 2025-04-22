# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
json.email_address @supporter.email
json.status "subscribed"

json.merge_fields do
  json.F_NAME @supporter.calculated_first_name
  json.L_NAME @supporter.calculated_last_name

  @supporter.recurring_donations.active.order("start_date DESC").each_with_index do |item, i|
    json.set! "RD_URL_#{i + 1}", # we use i+1 because we want this to start at RD_URL_1
      edit_recurring_donation_url(id: item.id, t: item.edit_token, host: "us.commitchange.com")
  end
end
