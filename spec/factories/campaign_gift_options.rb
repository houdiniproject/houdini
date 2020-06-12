# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
FactoryBot.define do
  factory :campaign_gift_option do
    sequence(:name) { |i| "name_#{i}" }
    campaign
    amount_one_time { 200 }
  end
end
