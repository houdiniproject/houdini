require 'active_record'
require 'qx'
require 'pg'
Qx.config(type_map: PG::BasicTypeMapForResults.new(ActiveRecord::Base.connection.raw_connection))
Qx.execute("SET TIME ZONE utc")

