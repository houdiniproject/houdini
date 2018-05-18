# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later

CarrierWave.configure do |config|
	config.storage    = :aws
	config.aws_bucket = Settings.aws.bucket
	config.aws_acl    = :public_read
	config.asset_host = Settings.image&.host || "https://s3-#{Settings.aws.region}.amazonaws.com/#{Settings.aws.bucket}"
	config.aws_authenticated_url_expiration = 60 * 60 * 24 * 365
	config.aws_credentials = {
		access_key_id:     Settings.aws.access_key_id,
		secret_access_key: Settings.aws.secret_access_key,
		config: AWS.config(cache_dir: "#{Rails.root}/tmp/uploads", region: Settings.aws.region)
	}
end
