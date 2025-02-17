# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
FactoryBot.define do
  factory :nm_justice, class: "Nonprofit" do
    id { 55352 }
    name { "New Mexico Justice" }
    city { "Albuquerque" }
    state_code { "NM" }
    zip_code { 55_555 }
    email { "nmj@gmail.com" }
    slug { "new-mexico-equality" }
    state_code_slug { "nm" }
    city_slug { "albuquerque" }
    register_np_only { true }
  end

  factory :fv_poverty, class: "Nonprofit" do
    id { 22352 }
    name { "Ending Poverty in the Fox Valley Inc." }
    city { "Appleton" }
    state_code { "WI" }
    zip_code { 54915 }
    email { "contact@endpovertyinthefoxvalleyinc.org" }
    website { "https://endpovertyinthefoxvalleyinc.org" }
    slug { "end-poverty-in-the-fox-valley-inc" }
    state_code_slug { "wi" }
    city_slug { "appleton" }
    register_np_only { true }
  end

  factory :nonprofit_base, class: "Nonprofit" do
    name { "Ending Poverty in the Fox Valley Inc." }
    city { "Appleton " }
    state_code { "wi" }
    sequence(:slug) { |n| "#{n}-end-poverty-in-the-fox-valley-inc" }
    state_code_slug { "wi" }
    city_slug { "appleton" }
  end
end
