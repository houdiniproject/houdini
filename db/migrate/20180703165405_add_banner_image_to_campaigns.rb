# frozen_string_literal: true

class AddBannerImageToCampaigns < ActiveRecord::Migration
  def change
    add_column :campaigns, :banner_image, :string
  end
end
