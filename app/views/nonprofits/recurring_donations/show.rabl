# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
object @recurring_donation => :data
attributes :id, :total_given, :supporter_id, :interval, :time_unit, :designation, :anonymous, :start_date, :end_date, :created_at, :paydate, :edit_token

child :donation do
  attributes :amount, :designation
end

child :supporter do
  attributes :name, :email, :id, :anonymous
end

child :card do
  attributes :name
end

node(:fee_covered) do |p|
  !!p.misc_recurring_donation_info&.fee_covered
end
