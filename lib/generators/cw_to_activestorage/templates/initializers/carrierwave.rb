# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later

CarrierWave.configure do |config|
    config.storage = :aws
    config.aws_bucket = ENV['CARRIERWAVE_AWS_BUCKET']
    config.aws_acl    = :public_read
    config.asset_host = ENV['CARRIERWAVE_IMAGE_HOST'] || "https://#{config.aws_bucket}.s3.amazonaws.com"
    # config.aws_authenticated_url_expiration = 60 * 60 * 24 * 365
    # config.aws_credentials = {
    #   access_key_id: ENV['CARRIERWAVE_AWS_ACCESS_KEY_ID'],
    #   secret_access_key: ENV['CARRIERWAVE_SECRET_ACCESS_KEY'],
    #   config: AWS.config(cache_dir: "#{Rails.root}/tmp/uploads", region: ENV['CARRIERWAVE_SECRET_ACCESS_KEY'])
    # }
end
  