# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module ChunkedUploader
  class S3
    MINIMUMBUFFER_SIZE = 5.megabytes

    S3_BUCKET_NAME = Settings.aws.bucket_name

    # Upload a string to s3 using chunks instead of all as one string. This is useful reducing memory usage on huge files
    # @param [Enumerable<String>] chunk_enum an enumerable of strings.
    # @param [String] path the path to the object on your S3 bucket
    # @returns the url to your uploaded file
    def self.upload(path,chunk_enum, metadata={})
      s3 = AWS::S3.new
      bucket = s3.buckets[S3_BUCKET_NAME]
      object = bucket.objects[path]
      io = StringIO.new('', 'w')
      content_type = metadata[:content_type] ?  metadata[:content_type] : nil
      content_disposition = metadata[:content_disposition] ?  metadata[:content_disposition] : nil
      begin
        object.multipart_upload(:acl => :public_read, :content_type => content_type, content_disposition: content_disposition) do |upload|
          chunk_enum.each  do |chunk|
            export_returned = io.write(chunk)
            if (io.size >= MINIMUMBUFFER_SIZE)
              upload.add_part(io.string)
              io.reopen('')
            end
          end
          upload.add_part(io.string)
        end
        object.public_url.to_s
      rescue => e
        io.close
        raise e
      end
    end
  end
end