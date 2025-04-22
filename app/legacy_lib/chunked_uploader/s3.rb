# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module ChunkedUploader
  class S3
    S3_BUCKET_NAME = Settings.aws.bucket_name

    # Upload a string to s3 using chunks instead of all as one string. This is useful reducing memory usage on huge files
    # @param [Enumerable<String>] chunk_enum an enumerable of strings.
    # @param [String] path the path to the object on your S3 bucket
    # @returns the url to your uploaded file
    def self.upload(path, chunk_enum, metadata = {})
      s3 = ::Aws::S3::Resource.new
      bucket = s3.bucket(S3_BUCKET_NAME)
      object = bucket.object(path)
      content_type = metadata[:content_type] || nil
      content_disposition = metadata[:content_disposition] || nil

      object.upload_stream(temp_file: true, acl: "public-read", content_type: content_type, content_disposition: content_disposition) do |write_stream|
        chunk_enum.each do |chunk|
          write_stream << chunk
        end
      end

      object.public_url.to_s
    end
  end
end
