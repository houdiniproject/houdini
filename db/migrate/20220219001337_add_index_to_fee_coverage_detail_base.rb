class AddIndexToFeeCoverageDetailBase < ActiveRecord::Migration
  def change
    add_index :fee_coverage_detail_bases, :fee_era_id
  end
end
