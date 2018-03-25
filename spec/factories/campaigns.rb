FactoryBot.define do
  factory :campaign do
    profile
    nonprofit
    sequence(:name) {|i| "name #{i}"}
    sequence(:slug) {|i| "slug_#{i}"}
  end
end
