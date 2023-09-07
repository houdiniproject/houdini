class AddTimestampsToDripEmailList < ActiveRecord::Migration
  def change
    add_timestamps :drip_email_lists, null: false
  end
end
