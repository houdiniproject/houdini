class CreateFeeErasStructuresAndCoverDetailBases < ActiveRecord::Migration
  def create_record(sql_command)
    execute(sql_command).getvalue(0, 0).to_i
  end

  def get_fee_era_id(where_clause)
    execute(<<-SQL
      SELECT id from fee_eras WHERE #{where_clause};
    SQL
           ).getvalue(0, 0).to_i
  end

  def delete_fee_era_id(where_clause)
    fee_era_id = get_fee_era_id(where_clause)

    execute <<-SQL
      DELETE FROM fee_structures WHERE fee_era_id=#{fee_era_id};
    SQL

    execute <<-SQL
      DELETE FROM fee_coverage_detail_bases WHERE fee_era_id=#{fee_era_id};
    SQL

    execute <<-SQL
      DELETE FROM fee_eras WHERE id=#{fee_era_id};
    SQL
  end

  def change
    create_table :fee_eras do |t|
      t.datetime :start_time
      t.datetime :end_time

      t.string :local_country
      t.decimal :international_surcharge_fee

      t.boolean :refund_stripe_fee, default: false

      t.timestamps null: false
    end

    create_table :fee_structures do |t|
      t.string :brand
      t.integer :flat_fee
      t.decimal :stripe_fee
      t.references :fee_era, required: true, foreign_key: true

      t.timestamps null: false
    end

    create_table :fee_coverage_detail_bases do |t|
      t.integer :flat_fee
      t.decimal :percentage_fee
      t.boolean :dont_consider_billing_plan, null: false, default: false
      t.references :fee_era, required: true, foreign_key: true

      t.timestamps null: false
    end

    reversible do |dir|
      dir.up do
        oldest_fee_era = create_record <<-SQL
          INSERT INTO fee_eras (end_time, refund_stripe_fee, created_at, updated_at) 
          VALUES (to_timestamp(1601510400), true, now(), now())
          RETURNING id;
        SQL

        execute <<-SQL
          INSERT INTO fee_structures (fee_era_id, flat_fee, stripe_fee, created_at, updated_at)
          VALUES (#{oldest_fee_era}, 30, 0.022, now(), now())
        SQL

        execute <<-SQL
          INSERT INTO fee_coverage_detail_bases (fee_era_id, flat_fee, percentage_fee, created_at, updated_at)
          VALUES (#{oldest_fee_era}, 30, 0.022, now(), now())
        SQL

        middle_fee_era = create_record <<-SQL
          INSERT INTO fee_eras (start_time, end_time, local_country, international_surcharge_fee, created_at, updated_at) 
          VALUES (to_timestamp(1601510400), to_timestamp(1627696800), 'US',  0.01, now(), now())
          RETURNING id;
        SQL

        execute <<-SQL
          INSERT INTO fee_structures (fee_era_id, flat_fee, stripe_fee, created_at, updated_at)
          VALUES (#{middle_fee_era}, 30, 0.022, now(), now())
        SQL

        execute <<-SQL
          INSERT INTO fee_structures (fee_era_id, flat_fee, stripe_fee, created_at, updated_at, brand)
          VALUES (#{middle_fee_era}, 0, 0.035,  now(), now(), 'American Express')
        SQL

        execute <<-SQL
          INSERT INTO fee_coverage_detail_bases (fee_era_id, flat_fee, percentage_fee, created_at, updated_at, dont_consider_billing_plan)
          VALUES (#{middle_fee_era}, 0, 0.05, now(), now(), true)
        SQL

        latest_fee_era = create_record <<-SQL
          INSERT INTO fee_eras (start_time, local_country, international_surcharge_fee,created_at, updated_at) 
          VALUES (to_timestamp(1627696800), 'US',  0.01, now(), now())
          RETURNING id;
        SQL

        execute <<-SQL
          INSERT INTO fee_structures (fee_era_id, flat_fee, stripe_fee, created_at, updated_at)
          VALUES (#{latest_fee_era}, 25, 0.02, now(), now())
        SQL

        execute <<-SQL
          INSERT INTO fee_coverage_detail_bases (fee_era_id, flat_fee, percentage_fee, created_at, updated_at)
          VALUES (#{latest_fee_era}, 25, 0.02, now(), now())
        SQL
      end

      dir.down do
        delete_fee_era_id("end_time = to_timestamp(1601510400)")
        delete_fee_era_id("start_time = to_timestamp(1601510400) AND end_time = to_timestamp(1627696800)")
        delete_fee_era_id("start_time = to_timestamp(1627696800)")
      end
    end
  end
end
