# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
FactoryBot.define do
  factory :user, aliases: [:user_base] do
    sequence(:email) { |i| "user#{i}@example.string.com" }
    password { "whocares" }
    trait :confirmed do
      confirmed_at { Time.current - 1.day }
    end
  end

  factory :automated_user, class: User do
    email { "automated_user@automated_user.user" }
    password { "whocares" }
    id { 540 }
  end

  factory :user_as_nonprofit_admin, class: User do
    transient do
      nonprofit { create(:nonprofit_base) }
    end

    sequence(:email) { |i| "user_nonprofit_admin#{i}@example.string.com" }
    password { "whocares" }
    roles {
      [
        build(:role, name: "nonprofit_admin", host: nonprofit)
      ]
    }
  end

  factory :user_as_nonprofit_associate, class: User do
    transient do
      nonprofit { create(:nonprofit_base) }
    end

    sequence(:email) { |i| "user_nonprofit_associate#{i}@example.string.com" }
    password { "whocares" }
    roles {
      [
        build(:role, name: "nonprofit_associate", host: nonprofit)
      ]
    }

    trait :with_first_name do
      name { Faker::Name.first_name }
    end
  end

  factory :user_as_super_admin, class: User do
    transient do
      nonprofit { create(:nonprofit_base) }
    end
    sequence(:email) { |i| "user#{i}@example.string.com" }
    password { "whocares" }
    roles {
      [
        build(:role, name: "nonprofit_associate", host: create(:nonprofit_base)),
        build(:role, name: "super_admin")
      ]
    }
  end
end
