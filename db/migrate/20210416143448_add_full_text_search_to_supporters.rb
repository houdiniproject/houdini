class AddFullTextSearchToSupporters < ActiveRecord::Migration
  def up
    add_column :supporters, :fts, :tsvector

    execute(<<-EOSQL.strip)
      UPDATE supporters SET fts = (to_tsvector('english', coalesce(name, '') || ' ' || coalesce(email, '')));

      CREATE FUNCTION update_fts_on_supporters() RETURNS TRIGGER AS $$
        BEGIN
          new.fts = to_tsvector('english', coalesce(new.name, '') || ' ' || coalesce(new.email, ''));
          RETURN new;
        END
      $$ LANGUAGE plpgsql;

      CREATE TRIGGER update_supporters_fts BEFORE INSERT OR UPDATE
        ON supporters FOR EACH ROW EXECUTE PROCEDURE update_fts_on_supporters();
    EOSQL
  end

  def down
    execute(<<-EOSQL.strip)
      DROP FUNCTION update_fts_on_supporters () CASCADE;
      DROP TRIGGER IF EXISTS update_supporters_fts ON supporters;
    EOSQL
    remove_column :supporters, :fts
  end
end
