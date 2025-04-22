# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
json.data recurring_donation do |rd|
  json.extract! rd, :id, :total_given,
    :supporter_id, :interval,
    :time_unit, :designation,
    :anonymous, :start_date, :end_date,
    :created_at, :paydate, :edit_token
  json.donation recurring_donation.donation do |d|
    json.extract! d, :id, :amount, :designation
  end

  json.supporter recurring_donation.supporter do |s|
    json.extract! s, :name, :email, :id, :anonymous
  end

  json.card recurring_donation.card do |c|
    json.extract! c, :name
  end
end
