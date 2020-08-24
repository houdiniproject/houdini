class ConvertActivityJsonDataToJsonb < ActiveRecord::Migration
  def up
    execute <<-SQL
      ALTER TABLE "activities" ALTER COLUMN "json_data" TYPE jsonb USING json_data::jsonb
    SQL
  end

  def down
    execute <<-SQL
      ALTER TABLE "activities" ALTER COLUMN "json_data" TYPE text USING json_data::text
    SQL
  end
end
