class AddFkToPaymentsToSupporters < ActiveRecord::Migration
  def up
    execute <<-SQL
      ALTER TABLE payments ADD CONSTRAINT payments_supporter_fk FOREIGN KEY (supporter_id) REFERENCES supporters(id);
    SQL
  end

  def down
    execute <<-SQL
      ALTER TABLE payments DROP CONSTRAINT payments_supporter_fk
    SQL
  end
end
