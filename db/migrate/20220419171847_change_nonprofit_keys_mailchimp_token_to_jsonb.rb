class ChangeNonprofitKeysMailchimpTokenToJsonb < ActiveRecord::Migration
  def up
    execute <<-SQL
      ALTER TABLE "nonprofit_keys" ALTER COLUMN "mailchimp_token" TYPE jsonb USING mailchimp_token::jsonb
    SQL
  end

  def down
    execute <<-SQL
      ALTER TABLE "nonprofit_keys" ALTER COLUMN "mailchimp_token" TYPE text USING mailchimp_token::text
    SQL
  end
end
