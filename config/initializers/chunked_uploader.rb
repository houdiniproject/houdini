# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
CHUNKED_UPLOADER = ENV['CHUNKED_UPLOAD_CLASS'] ? ENV['CHUNKED_UPLOAD_CLASS'].constantize : ChunkedUploader::S3