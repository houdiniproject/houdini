class AddOrganizationToFtsIndex < ActiveRecord::Migration
  def drop_fts_triggers
    execute(<<-EOSQL.strip)
      DROP FUNCTION update_fts_on_supporters () CASCADE;
      DROP TRIGGER IF EXISTS update_supporters_fts ON supporters;
    EOSQL
  end

  def up
    drop_fts_triggers
    execute(<<-EOSQL.strip)

      CREATE FUNCTION update_fts_on_supporters() RETURNS TRIGGER AS $$
        BEGIN
          new.fts = to_tsvector('english', coalesce(new.name, '') || ' ' || coalesce(new.email, '') || ' ' || coalesce(new.organization, ''));
          RETURN new;
        END
      $$ LANGUAGE plpgsql;

      CREATE TRIGGER update_supporters_fts BEFORE INSERT OR UPDATE
        ON supporters FOR EACH ROW EXECUTE PROCEDURE update_fts_on_supporters();
    EOSQL
  end

  def down
    drop_fts_triggers
    execute(<<-EOSQL.strip)

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
end
