# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
module ChunkedUploader
  # Copy a string using chunks instead of all as one string. This is useful reducing memory usage when you want to do a huge export
  #
  # This code copies each chunk to a tempfile and then opens the tempfile and passes the IO object to the block
  # @param [Enumerable<String>] chunk_enum an enumerable of strings.
  # @block accepts an IO for passing to upload
  def self.upload(chunk_enum, &block)
    file_name = File.join(Dir.tmpdir, SecureRandom.uuid)

    File.open(file_name, "w") do |file|
      chunk_enum.each do |chunk|
        file.write(chunk)
      end
    end

    File.open(file_name, "r") do |file|
      yield(file)
    end

    File.delete(file_name)
  end
end
