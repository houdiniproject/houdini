class AddOrganizationToFtsIndex < ActiveRecord::Migration

  def drop_fts_triggers
    execute(<<-'eosql'.strip)
      DROP FUNCTION update_fts_on_supporters () CASCADE;
      DROP TRIGGER IF EXISTS update_supporters_fts ON supporters;
    eosql
  end

  def up
    drop_fts_triggers
    execute(<<-'eosql'.strip)
      UPDATE supporters SET fts = to_tsvector('english', coalesce(name, '') || ' ' || coalesce(email, '') || ' ' || coalesce(organization, ''));

      CREATE FUNCTION update_fts_on_supporters() RETURNS TRIGGER AS $$
        BEGIN
          new.fts = to_tsvector('english', coalesce(new.name, '') || ' ' || coalesce(new.email, '') || ' ' || coalesce(new.organization, ''));
          RETURN new;
        END
      $$ LANGUAGE plpgsql;

      CREATE TRIGGER update_supporters_fts BEFORE INSERT OR UPDATE
        ON supporters FOR EACH ROW EXECUTE PROCEDURE update_fts_on_supporters();
    eosql
    
  end

  def down

    drop_fts_triggers
    execute(<<-'eosql'.strip)
      UPDATE supporters SET fts = (to_tsvector('english', coalesce(name, '') || ' ' || coalesce(email, '')));

      CREATE FUNCTION update_fts_on_supporters() RETURNS TRIGGER AS $$
        BEGIN
          new.fts = to_tsvector('english', coalesce(new.name, '') || ' ' || coalesce(new.email, ''));
          RETURN new;
        END
      $$ LANGUAGE plpgsql;

      CREATE TRIGGER update_supporters_fts BEFORE INSERT OR UPDATE
        ON supporters FOR EACH ROW EXECUTE PROCEDURE update_fts_on_supporters();
    eosql
  end
end
