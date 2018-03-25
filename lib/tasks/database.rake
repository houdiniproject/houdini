Rake::Task["db:structure:dump"].clear
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