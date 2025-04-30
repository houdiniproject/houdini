# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
FactoryBot.define do
  factory :supporter do
    name { "Fake Supporter Name" }
    nonprofit

    trait :has_a_card do
      after(:create) { |supporter|
        create(:active_card_1, holder: supporter)
      }
    end
  end

  factory :supporter_generator, class: "Supporter" do
    sequence(:id)

    name { Faker::Name.name }
    email { Faker::Internet.email }
    nonprofit

    before(:create) do |supporter|
      supporter.id = nil if supporter.id
    end
  end

  trait :with_primary_address do
    addresses { [build(:supporter_address)] }
    primary_address { addresses.first }
  end

  factory :supporter_with_fv_poverty, aliases: [:supporter_base], class: "Supporter" do
    name { "Fake Supporter Name" }
    nonprofit { association :nonprofit_base, vetted: true }
    trait :with_1_active_mailing_list do
      nonprofit { association :nonprofit_base, :with_active_mailing_list }
      after(:create) do |supporter|
        supporter.tag_joins.create(tag_master: supporter.nonprofit.tag_masters.where("NOT deleted").first)
      end
    end
  end
end
