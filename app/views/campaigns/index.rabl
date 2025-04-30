# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
object false

child @campaigns => :data do
  collection @campaigns, object_root: false
  attributes :name, :total_raised, :goal_amount, :url, :id
end
