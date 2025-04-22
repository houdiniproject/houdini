# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rspec"
require "rails_helper"

describe ChunkedUploader::S3 do
  context ".upload" do
    skip "Only run this if you are okay getting billed on s3" do
      before(:each) do
        WebMock.disable!
        @s3 = Aws::S3.new
        @bucket = @s3.buckets[ENV["S3_BUCKET_NAME"]]
        @path = "tmp/export/1000000000.csv"
        @object = @bucket.objects[@path]
      end
      after(:each) do
        @object.delete
        WebMock.enable!
      end
      it "uploads empty properly" do
        ChunkedUploader::S3.upload(@path, [], content_type: "text/csv")

        info = @object.read.to_s

        expect(info).to eq("")
      end

      it "uploads very small properly" do
        input = 'row11,row12\nrow21,row22\n'
        ChunkedUploader::S3.upload(@path, [input], content_type: "text/csv")

        info = @object.read.to_s

        expect(info).to eq(input)

        pending("NOTE: METADATA CHECKING ISNT WORKING SO WE SKIP IT FOR NOW")
        metadata = @object.metadata

        puts metadata
        expect(metadata["Content-Type"]).to eq("text/csv")
      end

      it "uploads very large single properly" do
        temp = StringIO.new
        500_000.times { temp << 'row11,row12\n' }
        ChunkedUploader::S3.upload(@path, [temp.string])

        info = @object.read.to_s

        expect(info).to eq(temp.string)

        pending("NOTE: METADATA CHECKING ISNT WORKING SO WE SKIP IT FOR NOW")
        metadata = @object.metadata
        expect(metadata["Content-Type"]).to eq("text/csv")
      end

      it "uploads properly" do
        input_item = StringIO.new
        input = Enumerator.new do |y|
          temp = StringIO.new
          300_000.times { temp << 'row11,row12\n' }
          input_item.write(temp.string)
          y << temp.string
          temp = StringIO.new
          300_000.times { temp << 'row21,row22\n' }
          input_item.write(temp.string)
          y << temp.string
          temp = StringIO.new
          300_000.times { temp << 'row31,row32\n' }
          input_item.write(temp.string)
          y << temp.string
        end.lazy
        ChunkedUploader::S3.upload(@path, input, content_type: "text/csv")

        info = @object.read.to_s

        expect(info).to eq(input_item.string)
        pending("NOTE: METADATA CHECKING ISNT WORKING SO WE SKIP IT FOR NOW")
        metadata = @object.metadata
        expect(metadata["Content-Type"]).to eq("text/csv")
      end
    end
  end
end
