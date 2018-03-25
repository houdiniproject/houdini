class AddExternalIdentifierToCampaign < ActiveRecord::Migration
  def change
    add_column :campaigns, :external_identifier, :string
  end
end
