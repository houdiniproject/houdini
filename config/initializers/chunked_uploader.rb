# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
CHUNKED_UPLOADER_SERVICE = ENV['CHUNKED_UPLOADER_SERVICE'] ? ActiveStorage::Service.configure(
    ENV['CHUNKED_UPLOADER_SERVICE'], 
    Rails.configuration.active_storage.service_configurations) : ActiveStorage::Blob.service
