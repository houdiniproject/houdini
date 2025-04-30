class AddSupportersFtsIndex < ActiveRecord::Migration
  disable_ddl_transaction!
  def up
    execute(<<-EOSQL.strip)
      CREATE INDEX CONCURRENTLY supporters_fts_idx ON supporters USING gin(fts);
    EOSQL
  end

  def down
    execute(<<-EOSQL.strip)
      DROP INDEX IF EXISTS supporters_fts_idx;
    EOSQL
  end
end
