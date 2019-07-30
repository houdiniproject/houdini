# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class TestChunkedUploader
  TEST_ERROR_MESSAGE = 'test exception thrown'
  def self.clear
    @@output = nil
    @@raise_error = false
    @@options = nil
  end

  def self.output
    @@output
  end

  ## use this to throw an exception instead of finishing
  def self.raise_error
    @@raise_error = true
  end

  def self.options
    @@options
  end

  def self.upload(path, chunk_enum, options = {})
    @@options = options
    io = StringIO.new('', 'w')
    chunk_enum.each do |chunk|
      io.write(chunk)
    end
    raise TEST_ERROR_MESSAGE if @@raise_error

    @@output = io.string
    'http://fake.url/' + path
  end
end
