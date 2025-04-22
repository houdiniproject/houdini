# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later

Aws.config.update({
  region: Settings.aws.region || "us-west-1", # I'm hardcoding this because it's our damn code.
  credentials: Aws::Credentials.new(Settings.aws.access_key_id, Settings.aws.secret_access_key)
})

s3 = Aws::S3::Resource.new
S3Bucket = s3.bucket(Settings.aws.bucket)
