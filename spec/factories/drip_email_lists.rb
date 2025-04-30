# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later

FactoryBot.define do
  factory :drip_email_list do
  end

  factory :drip_email_list_base, class: "DripEmailList" do
    sequence(:mailchimp_list_id) { |i| "mailchimp_list_id#{i}" }
  end
end
