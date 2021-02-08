# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
class ConvertDonationDedicationToJsonb < ActiveRecord::Migration[6.1]
  def up
    execute <<-SQL
      ALTER TABLE "donations" ALTER COLUMN "dedication" TYPE jsonb USING dedication::jsonb
    SQL
  end

  def down
    execute <<-SQL
      ALTER TABLE "donations" ALTER COLUMN "dedication" TYPE text USING dedication::text
    SQL
  end
end
