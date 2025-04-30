# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later

json.email_address @user.email
json.status "subscribed"

json.merge_fields do
  json.NP_ID @nonprofit.id
  json.NP_SUPP @nonprofit.supporters.not_deleted.count
  json.FNAME @user.calculated_first_name || ""
end
