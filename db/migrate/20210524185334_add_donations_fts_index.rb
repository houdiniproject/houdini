class AddDonationsFtsIndex < ActiveRecord::Migration
  disable_ddl_transaction!
  def up
    execute(<<-'eosql'.strip)
      CREATE INDEX CONCURRENTLY donations_fts_idx ON donations USING gin(fts);
    eosql
  end

  def down
    execute(<<-'eosql'.strip)
      DROP INDEX IF EXISTS donations_fts_idx;
    eosql
  end
end
