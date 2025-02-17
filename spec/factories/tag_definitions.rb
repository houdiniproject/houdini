# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
FactoryBot.define do
  factory :tag_definition do
    factory :tag_definition_with_nonprofit do
      name { "Tag Name" }
      nonprofit { create(:fv_poverty) }
    end
  end
end
