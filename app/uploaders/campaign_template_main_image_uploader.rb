# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class CampaignTemplateMainImageUploader < CarrierWave::Uploader::Base
	include CarrierWave::MiniMagick

	def store_dir
		"uploads/campaign_templates/#{mounted_as}/#{model.id}"
	end

	def default_url
		return Image::DefaultProfileUrl
	end

	version :normal do
		process :resize_to_fill => [524, 360]
	end

	version :thumb do
		process :resize_to_fill => [180, 150]
	end

	def extension_white_list
		%w(jpg jpeg png)
	end

	def cache_dir
		"#{Rails.root}/tmp/uploads"
	end
end
