# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later

class NonprofitS3Key < ApplicationRecord
  belongs_to :nonprofit, optional: false

  validates :access_key_id, :secret_access_key, :bucket_name, :region, presence: true

  def aws_client
    ::Aws::S3::Client.new(credentials: credentials, region: region)
  end

  def credentials
    ::Aws::Credentials.new(access_key_id, secret_access_key)
  end

  def s3_resource
    ::Aws::S3::Resource.new(client: aws_client)
  end

  def s3_bucket
    s3_resource.bucket(bucket_name)
  end
end
