class AddFullTextSearchToDonations < ActiveRecord::Migration
  def up
    add_column :donations, :fts, :tsvector

    execute(<<-EOSQL.strip)
      UPDATE donations SET fts = (to_tsvector('english', coalesce(comment, '')));

      CREATE FUNCTION update_fts_on_donations() RETURNS TRIGGER AS $$
        BEGIN
          new.fts = to_tsvector('english', coalesce(new.comment, ''));
          RETURN new;
        END
      $$ LANGUAGE plpgsql;

      CREATE TRIGGER update_donations_fts BEFORE INSERT OR UPDATE
        ON donations FOR EACH ROW EXECUTE PROCEDURE update_fts_on_donations();
    EOSQL
  end

  def down
    execute(<<-EOSQL.strip)
      DROP FUNCTION update_fts_on_donations () CASCADE;
      DROP TRIGGER IF EXISTS update_donations_fts ON donations;
    EOSQL
    remove_column :donations, :fts
  end
end
