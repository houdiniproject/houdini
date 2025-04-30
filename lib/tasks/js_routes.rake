# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE

# rubocop:disable Rake/Desc -- we're enhancing a task we didn't create so no description

# adds support for generating js routes as part of the assets:precompile task
namespace :assets do
  task precompile: "js:routes:typescript"
end

# rubocop:enable Rake/Desc
