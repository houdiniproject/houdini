# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
FactoryBot.define do
  factory :nm_justice, class: Nonprofit do
    id { 55352 }
    name { 'New Mexico Justice' }
    city { 'Albuquerque' }
    state_code { 'NM' }
    zip_code { 55_555 }
    email { 'nmj@gmail.com' }
    slug { 'new_mexican_equality' }
    state_code_slug { 'nm'}
    city_slug { 'albuquerque'}
  end

  factory :fv_poverty, class: Nonprofit do
    id { 22352 }
    name { 'Ending Poverty in the Fox Valley Inc.' }
    city { 'Appleton' }
    state_code { 'WI' }
    zip_code { 54915 }
    email { 'contact@endpovertyinthefoxvalleyinc.org' }
    website {'https://endpovertyinthefoxvalleyinc.org'}
    slug { 'end_poverty_in_the_fox_valley_inc' }
    state_code_slug { 'wi'}
    city_slug { 'appleton'}
  end
end
