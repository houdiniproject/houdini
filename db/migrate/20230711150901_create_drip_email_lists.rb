class CreateDripEmailLists < ActiveRecord::Migration
  def change
    create_table :drip_email_lists do |t|
      t.string :mailchimp_list_id, required: true
    end
  end
end
