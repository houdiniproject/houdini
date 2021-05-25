class AddSupportersFtsIndex < ActiveRecord::Migration
  disable_ddl_transaction!
  def up
    execute(<<-'eosql'.strip)
      CREATE INDEX CONCURRENTLY supporters_fts_idx ON supporters USING gin(fts);
    eosql
  end

  def down
    execute(<<-'eosql'.strip)
      DROP INDEX IF EXISTS supporters_fts_idx;
    eosql
  end
end
