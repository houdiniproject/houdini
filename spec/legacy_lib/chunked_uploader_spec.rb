# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"

describe "ChunkedUploader" do
  let(:input) { ['something\nexit', 'anotherbreak\n'] }
  let(:result) { 'something\nexitanotherbreak\n' }

  it "sends a File to the block" do
    ChunkedUploader.upload(input) do |io|
      expect(io.class).to eq File
    end
  end

  it "it sends the accurate result to the block" do
    ChunkedUploader.upload(input) do |io|
      expect(io.read).to eq result
    end
  end

  describe "chunked uploads" do
    let(:input) { (['something\nexit', 'anotherbreak\n'] * 200000).flatten }
    let(:result) { 'something\nexitanotherbreak\n' * 200000 }
    let(:key) { "root/middle/child" }

    it "file service uploads 5MB+ file" do
      ChunkedUploader.upload(input) do |io|
        ActiveStorage::Blob.service.upload(key, io)
      end
      expect(ActiveStorage::Blob.service.download(key)).to eq result
    end

    describe "s3" do
      xit "uploads 5MB+ file" do
        s3_test = ActiveStorage::Service.configure(:s3_test, Rails.configuration.active_storage.service_configurations)
        ChunkedUploader.upload(input) do |io|
          s3_test.upload(key, io)
        end
        expect(s3_test.download(key)).to eq result
      end
    end
  end
end
