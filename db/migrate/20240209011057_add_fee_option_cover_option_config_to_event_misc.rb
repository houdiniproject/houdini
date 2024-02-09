class AddFeeOptionCoverOptionConfigToEventMisc < ActiveRecord::Migration
  def change
    add_column :misc_event_infos, :fee_coverage_option_config, :string, default: nil, nullable: true
  end
end
