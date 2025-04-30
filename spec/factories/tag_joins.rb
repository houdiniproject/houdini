# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
FactoryBot.define do
  factory :tag_join do
    tag_master_id { 1 }
    supporter_id { 4 }
    created_at { DateTime.now }
    updated_at { DateTime.now }
  end

  factory :tag_join_base, class: "TagJoin" do
    tag_master { association :tag_master_base }
  end
end
