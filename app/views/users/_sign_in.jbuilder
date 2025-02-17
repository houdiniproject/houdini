# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE

json.i18n do
  json.locale "en"
end

json.hoster do
  json.call(Houdini.hoster, :legal_name, :casual_name)
end
