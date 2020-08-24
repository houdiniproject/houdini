class ChangePaymentRefundTotalToDefaultToZero < ActiveRecord::Migration
  def change
    execute <<-SQL
      ALTER TABLE "payments" ALTER COLUMN "refund_total" SET DEFAULT 0;
    SQL

    execute <<-SQL
      UPDATE payments SET refund_total=0 WHERE refund_total IS NULL; 
    SQL
  end
end
