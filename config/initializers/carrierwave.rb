# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
if Rails.env.test?
  CarrierWave.configure do |config|
    config.storage = :file
    config.enable_processing = false
  end
elsif Rails.env.development?
  CarrierWave.configure do |config|
    config.ignore_integrity_errors = false
    config.ignore_processing_errors = false
    config.ignore_download_errors = false
  end
else
  CarrierWave.configure do |config|
    config.storage = :aws
    config.aws_bucket = Settings.aws.bucket
    config.aws_acl = :public_read
    config.asset_host = Settings.image&.host || "https://#{Settings.aws.bucket}.s3.amazonaws.com"
    config.aws_authenticated_url_expiration = 60 * 60 * 24 * 365
    config.aws_credentials = {
      access_key_id: Settings.aws.access_key_id,
      secret_access_key: Settings.aws.secret_access_key,
      region: Settings.aws.region
    }
  end
end
