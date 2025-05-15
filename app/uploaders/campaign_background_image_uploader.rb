# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
# encoding: utf-8

class CampaignBackgroundImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  def store_dir
    "uploads/campaigns/#{mounted_as}/#{model.id}"
  end

  # Create different versions of your uploaded files:
  version :normal do
    process resize_to_fill: [1000, 600]
  end

  def extension_white_list
    %w[jpg jpeg png]
  end

  def cache_dir
    "#{Rails.root.join("tmp/uploads")}"
  end
end
