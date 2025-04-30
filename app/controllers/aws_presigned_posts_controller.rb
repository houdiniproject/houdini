# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class AwsPresignedPostsController < ApplicationController
  before_action :authenticate_user!

  # post /presigned_posts
  # Create some keys using the AWS gem so the user can do direct-to-S3 uploads
  # http://docs.aws.amazon.com/AWSRubySDK/latest/AWS/S3/PresignedPost.html
  def create
    uuid = SecureRandom.uuid
    p = S3Bucket.presigned_post({
      key: "tmp/#{uuid}/${filename}",
      success_action_status: "201",
      acl: "public-read",
      expires: 30.days.from_now
    })

    render json: {
      s3_presigned_post: p.fields.to_json,
      s3_direct_url: p.url,
      s3_uuid: uuid
    }
  end
end
