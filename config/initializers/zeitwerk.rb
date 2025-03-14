# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE

Rails.autoloaders.each do |autoloader|
  autoloader.inflector.inflect(
    "uuid" => "UUID",
    "html" => "HTML"
  )
end
