# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
FactoryBot.define do
  factory :tag_join do
    tag_master_id { 1 }
    supporter_id { 4 }
    created_at { DateTime.now }
    updated_at { DateTime.now }
  end
end
