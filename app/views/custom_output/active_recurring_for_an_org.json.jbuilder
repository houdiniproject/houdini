# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later

# expects Supoorter objects which represent a single email, i.e. we ran a group("supporters.email") on supporters

json.array! @supporter_group_by_email do |supporter_group|
  json.email supporter_group.email
  all_supporters = supporter_group.supporters.map { |id| Supporter.includes(:recurring_donations, tag_joins: :tag_master).find(id) }
  json.tags all_supporters.map { |s| s.tag_joins.joins(:tag_master).where("NOT tag_masters.deleted").references(:tag_masters).pluck("tag_masters.name") }.flatten
  recurrings = all_supporters.map { |supporter| supporter.recurring_donations.active.unfailed.order("start_date DESC") }.flatten.sort_by { |i| i.start_date }.reverse
  json.active_recurring_donations recurrings do |recurring|
    json.supporter_id recurring.supporter.id
    json.amount recurring.amount
    json.start_date recurring.start_date.to_datetime.utc.to_i
  end
end
