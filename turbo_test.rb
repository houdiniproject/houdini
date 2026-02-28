# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE

# based on code at: https://github.com/ioquatix/turbo_test/issues/6
ENV["RAILS_ENV"] = "test"

worker do |index|
  index += 1
  ENV["TEST_ENV_NUMBER"] = (index == 1) ? "" : index.to_s
  ENV["RAILS_ENV"] = "test"
  system("bin/rails", "db:environment:set", "RAILS_ENV=test")
  system("bin/rails", "db:drop", "db:create", "db:schema:load")
end
