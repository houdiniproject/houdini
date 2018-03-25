FactoryBot.define do
  factory :tag_join do
    tag_master_id 1
    supporter_id 4
    created_at DateTime.now
    updated_at DateTime.now
  end
end
