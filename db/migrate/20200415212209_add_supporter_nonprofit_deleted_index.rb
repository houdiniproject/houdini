class AddSupporterNonprofitDeletedIndex < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE INDEX supporters_nonprofit_id_not_deleted ON supporters (nonprofit_id, deleted) WHERE NOT deleted
    SQL
  end

  def down
    execute <<-SQL
    DROP INDEX supporters_nonprofit_id_not_deleted ON supporters;
    SQL
  end
end
