# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
ActiveSupport.on_load(:active_record) do
  Qx.config(type_map: PG::BasicTypeMapForResults.new(ActiveRecord::Base.connection.raw_connection))
  Qx.execute("SET TIME ZONE utc")
end

