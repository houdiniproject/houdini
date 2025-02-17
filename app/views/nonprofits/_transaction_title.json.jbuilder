# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE

json.innerProps do
  json.nonprofit do
    json.partial! "app_data/nonprofit", nonprofit: administered_nonprofit
  end

  json.active active
  json.page_name page_name
  json.icon_class icon_class
end
