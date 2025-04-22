# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class AddIndexesForPaymentAndSupporterQueries < ActiveRecord::Migration
  def up
    Qx.transaction do
      Qx.execute(%(
        CREATE INDEX IF NOT EXISTS payments_date ON payments (date);
        CREATE INDEX IF NOT EXISTS payments_gross_amount ON payments (gross_amount);
        CREATE INDEX IF NOT EXISTS payments_kind ON payments (kind);
        CREATE INDEX IF NOT EXISTS payments_towards ON payments (lower(towards));
        CREATE INDEX IF NOT EXISTS payments_donation_id ON payments (donation_id);
        CREATE INDEX IF NOT EXISTS payments_supporter_id ON payments (supporter_id);
        CREATE INDEX IF NOT EXISTS payments_nonprofit_id ON payments (nonprofit_id);

        CREATE INDEX IF NOT EXISTS supporters_created_at ON supporters (created_at) WHERE deleted != true;
        CREATE INDEX IF NOT EXISTS supporters_name ON supporters (lower(name)) WHERE deleted != true;
        CREATE INDEX IF NOT EXISTS supporters_email ON supporters (lower(email)) WHERE deleted != true;
        CREATE INDEX IF NOT EXISTS supporters_nonprofit_id ON supporters (nonprofit_id) WHERE deleted != true;

        CREATE INDEX IF NOT EXISTS donations_amount ON donations USING btree (amount);
        CREATE INDEX IF NOT EXISTS donations_designation ON donations USING btree (lower(designation));
        CREATE INDEX IF NOT EXISTS donations_supporter_id ON donations USING btree (supporter_id);

        CREATE INDEX IF NOT EXISTS tag_joins_supporter_id ON tag_joins (supporter_id);
        CREATE INDEX IF NOT EXISTS tag_joins_tag_master_id ON tag_joins (tag_master_id);

        CREATE INDEX IF NOT EXISTS custom_field_joins_custom_field_master_id ON custom_field_joins (custom_field_master_id);
      ))
    end
  end

  def down
    Qx.execute(%(
        DROP INDEX IF EXISTS payments_date;
        DROP INDEX IF EXISTS payments_gross_amount;
        DROP INDEX IF EXISTS payments_kind;
        DROP INDEX IF EXISTS payments_towards;
        DROP INDEX IF EXISTS payments_supporter_id;
        DROP INDEX IF EXISTS payments_nonprofit_id;

        DROP INDEX IF EXISTS supporters_created_at;
        DROP INDEX IF EXISTS supporters_name;
        DROP INDEX IF EXISTS supporters_email;
        DROP INDEX IF EXISTS supporters_nonprofit_id;
        DROP INDEX IF EXISTS supporters_donation_id;

        DROP INDEX IF EXISTS donations_amount;
        DROP INDEX IF EXISTS donations_designation;
        DROP INDEX IF EXISTS donations_supporter_id;

        DROP INDEX IF EXISTS tag_joins_supporter_id;
        DROP INDEX IF EXISTS tag_joins_tag_master_id;

        DROP INDEX IF EXISTS custom_field_joins_custom_field_master_id;
      ))
  end
end
