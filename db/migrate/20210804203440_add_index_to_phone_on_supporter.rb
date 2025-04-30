# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class AddIndexToPhoneOnSupporter < ActiveRecord::Migration
  def change
    add_column :supporters, :phone_index, :string
    reversible do |dir|
      dir.up do
        execute(<<-'EOSQL'.strip)
          CREATE FUNCTION update_phone_index_on_supporters() RETURNS TRIGGER AS $$
            BEGIN
              new.phone_index = (regexp_replace(new.phone, '\D','', 'g'));
              RETURN new;
            END
          $$ LANGUAGE plpgsql;
    
          CREATE TRIGGER update_supporters_phone_index BEFORE INSERT OR UPDATE
            ON supporters FOR EACH ROW EXECUTE PROCEDURE update_phone_index_on_supporters();
        EOSQL
      end

      dir.down do
        execute(<<-EOSQL.strip)
          DROP FUNCTION update_phone_index_on_supporters () CASCADE;
          DROP TRIGGER IF EXISTS update_supporters_phone_index ON supporters;
        EOSQL
      end
    end

    add_index :supporters, [:nonprofit_id, :phone_index, :deleted], where: "phone IS NOT NULL AND phone != ''"
  end
end
