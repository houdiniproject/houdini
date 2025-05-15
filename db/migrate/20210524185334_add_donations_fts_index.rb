class AddDonationsFtsIndex < ActiveRecord::Migration
  disable_ddl_transaction!
  def up
    execute(<<-EOSQL.strip)
      CREATE INDEX CONCURRENTLY donations_fts_idx ON donations USING gin(fts);
    EOSQL
  end

  def down
    execute(<<-EOSQL.strip)
      DROP INDEX IF EXISTS donations_fts_idx;
    EOSQL
  end
end
