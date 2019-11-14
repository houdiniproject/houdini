# frozen_string_literal: true

class AddBannerImageToCampaigns < ActiveRecord::Migration[4.2]
  def change
    add_column :campaigns, :banner_image, :string
  end
end
