class CampaignCustomBannerUploader < CarrierWave::Uploader::Base

	# Include RMagick or MiniMagick support:
	# include CarrierWave::RMagick
	include CarrierWave::MiniMagick

	# Include the Sprockets helpers for Rails 3.1+ asset pipeline compatibility:
	# include Sprockets::Helpers::RailsHelper
	# include Sprockets::Helpers::IsolatedHelper

	# Override the directory where uploaded files will be stored.
	# This is a sensible default for uploaders that are meant to be mounted:
	def store_dir
		"uploads/campaigns/#{mounted_as}/#{model.id}"
	end

	# Process files as they are uploaded:
	# process :scale => [200, 300]
	#
	# def scale(width, height)
	#		# do something
	# end

	# Add a white list of extensions which are allowed to be uploaded.
	# For images you might use something like this:
	def extension_white_list
		%w(jpg jpeg png)
	end

	# Override the filename of the uploaded files:
	# Avoid using model.id or version_name here, see uploader/store.rb for details.
	# def filename
	#		"something.jpg" if original_filename
	# end

	def cache_dir
		"#{Rails.root}/tmp/uploads"
	end
end
