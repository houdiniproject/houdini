# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
FactoryBot.define do
  factory :campaign do
    profile
    nonprofit_id { 55352 }
    sequence(:name) { |i| "name #{i}" }
    sequence(:slug) { |i| "slug_#{i}" }
  end
end
