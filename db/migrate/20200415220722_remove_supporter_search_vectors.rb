class RemoveSupporterSearchVectors < ActiveRecord::Migration
  def up
    execute <<-SQL
      DROP FUNCTION update_supporter_assoc_search_vectors();
    SQL

    execute <<-SQL
      DROP INDEX supporters_search_idx;
    SQL

    remove_column :supporters, :search_vectors
  end

  def down
    add_column :supporters, :search_vectors, "tsvector"

    execute <<~SQL
          CREATE FUNCTION public.update_supporter_assoc_search_vectors() RETURNS trigger
          LANGUAGE plpgsql
          AS $$ BEGIN
            IF pg_trigger_depth() <> 1 THEN RETURN new; END IF;
            UPDATE supporters
              SET search_vectors=to_tsvector('english', data.search_blob)
              FROM (
      SELECT supporters.id, concat_ws(' '
              , custom_field_joins.value
              , supporters.name
              , supporters.organization
              , supporters.id
              , supporters.email
              , supporters.city
              , supporters.state_code
              , donations.designation
              , donations.dedication
              , payments.kind
              , payments.towards
              ) AS search_blob
      FROM supporters 
      LEFT OUTER JOIN payments
        ON payments.supporter_id=supporters.id 
      LEFT OUTER JOIN donations
        ON donations.supporter_id=supporters.id 
      LEFT OUTER JOIN (
      SELECT string_agg(value::text, ' ') AS value, supporter_id
      FROM custom_field_joins 
      GROUP BY supporter_id) AS custom_field_joins
        ON custom_field_joins.supporter_id=supporters.id
      WHERE (supporters.id=NEW.supporter_id)) AS data
              WHERE data.id=supporters.id;
            RETURN new;
          END $$;
    SQL

    execute <<-SQL
    CREATE INDEX supporters_search_idx ON public.supporters USING gin (search_vectors);
    SQL
  end
end
