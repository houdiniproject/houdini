# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later

AWS.config({
  region: Settings.aws.region,
  access_key_id: Settings.aws.access_key_id,
  secret_access_key: Settings.aws.secret_access_key
})

s3 = AWS::S3.new
S3Bucket = s3.buckets[Settings.aws.bucket]
