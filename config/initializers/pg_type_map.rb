# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "active_record"
require "qx"
require "pg"
def database_exists?
  ActiveRecord::Base.connection
rescue ActiveRecord::NoDatabaseError
  false
else
  Qx.config(type_map: PG::BasicTypeMapForResults.new(ActiveRecord::Base.connection.raw_connection))
  Qx.execute("SET TIME ZONE utc")
end
