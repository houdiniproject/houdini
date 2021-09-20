class RemoveEmailUnsubscribeUuidFromSupporter < ActiveRecord::Migration
  def change
    remove_column :supporters, :email_unsubscribe_uuid, :string
  end
end
