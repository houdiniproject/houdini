FactoryBot.define do
  factory :email_list do
  end

  factory :email_list_base, class: "EmailList" do
    sequence(:list_name) { |i| "list_name#{i}" }
    sequence(:mailchimp_list_id) { |i| "mailchimp_list_id#{i}" }
    tag_master { build(:tag_master_base) }
    nonprofit { association :nonprofit_base }
    base_uri { "https://us3.api.mailchimp.com/3.0" }

    trait :without_base_uri do
      base_uri { nil }
    end
  end
end
