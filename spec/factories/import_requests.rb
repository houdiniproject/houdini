# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
FactoryBot.define do
  factory :import_request do
    header_matches { "" }
    nonprofit { "" }
    user_email { "MyString" }
  end
end
