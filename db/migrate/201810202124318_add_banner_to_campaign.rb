class AddBannerToCampaign < ActiveRecord::Migration
  def change
    add_column :campaigns, :custom_banner, :string
  end
end
