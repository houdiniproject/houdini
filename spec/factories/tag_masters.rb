# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
FactoryBot.define do
  factory :tag_master do
  end

  factory :tag_master_base, class: "TagMaster" do
    sequence(:name) { |i| "tag_name_#{i}" }
    deleted { false }

    trait :with_email_list do
      email_list { build(:email_list_base, nonprofit: nonprofit) }
    end
  end
end
