class AddPaymentProviderToDonations < ActiveRecord::Migration
  def change
    add_column :donations, :payment_provider, :string
  end
end
