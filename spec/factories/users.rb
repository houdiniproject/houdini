# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
FactoryBot.define do
  factory :user do
    sequence(:email) {|i| "user#{i}@example.string.com"}
    password "whocares"
  end

  factory :automated_user, class: User do 
    email { "automated_user@automated_user.user"}
    password "whocares"
    id { 540 }
  end
end
