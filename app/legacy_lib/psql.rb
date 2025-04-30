# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
# Some convenience wrappers around the postgresql gem, allowing us to avoid activerecord dependency
# combine usage of this library with Qexpr

require "colorize"

require "qx"

# Initialize the database connection

module Psql
  # Execute a sql statement (string)
  def self.execute(statement)
    puts statement if ENV["RAILS_ENV"] != "production" && ENV["RAILS_LOG_LEVEL"] == "debug" # log to STDOUT on dev/staging
    Qx.execute_raw(raw_expr_str(statement))
  end

  # A variation of execute that returns a vector of vectors rather than a vector of hashes
  # Useful and faster for creating CSV's
  def self.execute_vectors(statement)
    puts statement if ENV["RAILS_ENV"] != "production" && ENV["RAILS_LOG_LEVEL"] == "debug" # log to STDOUT on dev/staging
    statement.to_s.uncolorize.encode("UTF-8", "binary", invalid: :replace, undef: :replace, replace: "")
    Qx.execute_raw(raw_expr_str(statement), format: "csv")
  end

  def self.transaction(&block)
    Qx.transaction do
      yield block
    end
  end

  private

  # Raw expression string
  def self.raw_expr_str(statement)
    statement.to_s.uncolorize.encode("UTF-8", "binary", invalid: :replace, undef: :replace, replace: "")
  end
end
