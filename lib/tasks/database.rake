# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'active_record/connection_adapters/postgresql_adapter'
Rake::Task["db:structure:dump"].clear
class ActiveRecord::ConnectionAdapters::PostgreSQLAdapter
  def set_standard_conforming_strings
    old, self.client_min_messages = client_min_messages, 'warning'
    execute('SET standard_conforming_strings = on', 'SCHEMA') rescue nil
  ensure
    self.client_min_messages = old
  end

  #
  # Monkey-patch the refused Rails 4.2 patch at https://github.com/rails/rails/pull/31330
  # Changed the module/class hierarchy to work with Rails 3.2
  # Based on solution for Rails 4.2 https://github.com/rails/rails/issues/28780#issuecomment-354868174
  #
  # Updates sequence logic to support PostgreSQL 10.
  #
  # Resets the sequence of a table's primary key to the maximum value.
  def reset_pk_sequence!(table, pk = nil, sequence = nil) #:nodoc:
    unless pk and sequence
      default_pk, default_sequence = pk_and_sequence_for(table)

      pk ||= default_pk
      sequence ||= default_sequence
    end

    if @logger && pk && !sequence
      @logger.warn "#{table} has primary key #{pk} with no default sequence"
    end

    if pk && sequence
      quoted_sequence = quote_table_name(sequence)
      max_pk = select_value("SELECT MAX(#{quote_column_name pk}) FROM #{quote_table_name(table)}")
      if max_pk.nil?
        if postgresql_version >= 100000
          minvalue = select_value("SELECT seqmin FROM pg_sequence WHERE seqrelid = #{quote(quoted_sequence)}::regclass")
        else
          minvalue = select_value("SELECT min_value FROM #{quoted_sequence}")
        end
      end

      select_value <<-end_sql, 'SCHEMA'
      SELECT setval(#{quote(quoted_sequence)}, #{max_pk ? max_pk : minvalue}, #{max_pk ? true : false})
      end_sql
    end
  end
end

namespace :db do
  namespace :structure do
    desc "Overriding the task db:structure:dump task to remove -i option from pg_dump to make postgres 9.5 compatible"
    task dump: [:environment, :load_config] do
      config = ActiveRecord::Base.configurations[Rails.env]
      set_psql_env(config)
      filename =  File.join(Rails.root, "db", "structure.sql")
      database = config["database"]
      command = "pg_dump -s -x -O -f #{Shellwords.escape(filename)} #{Shellwords.escape(database)}"
      raise 'Error dumping database' unless Kernel.system(command)

      File.open(filename, "a") { |f| f << "SET search_path TO #{ActiveRecord::Base.connection.schema_search_path};\n\n" }
      if ActiveRecord::Base.connection.supports_migrations?
        File.open(filename, "a") do |f|
          f.puts ActiveRecord::Base.connection.dump_schema_information
          f.print "\n"
        end
      end
      Rake::Task["db:structure:dump"].reenable
    end
  end

  def set_psql_env(configuration)
    ENV['PGHOST']     = configuration['host']          if configuration['host']
    ENV['PGPORT']     = configuration['port'].to_s     if configuration['port']
    ENV['PGPASSWORD'] = configuration['password'].to_s if configuration['password']
    ENV['PGUSER']     = configuration['username'].to_s if configuration['username']
  end
end