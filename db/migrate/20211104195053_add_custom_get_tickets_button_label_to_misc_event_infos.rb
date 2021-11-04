class AddCustomGetTicketsButtonLabelToMiscEventInfos < ActiveRecord::Migration
  def change
    add_column :misc_event_infos, :custom_get_tickets_button_label, :string, default: nil
  end
end
