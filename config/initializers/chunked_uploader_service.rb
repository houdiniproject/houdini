# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later


ActiveSupport.on_load(:active_storage_blob) do
    CHUNKED_UPLOAD_SERVICE = ENV['CHUNKED_UPLOAD_SERVICE'] ? ActiveStorage::Service.configure(
        ENV['CHUNKED_UPLOAD_SERVICE'], 
        Rails.configuration.active_storage.service_configurations) : ActiveStorage::Blob.service
end


