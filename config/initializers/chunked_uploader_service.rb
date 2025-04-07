# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE

ActiveSupport.on_load(:active_storage_blob) do
  CHUNKED_UPLOAD_SERVICE = ENV["CHUNKED_UPLOAD_SERVICE"] ? ActiveStorage::Service.configure(
    ENV["CHUNKED_UPLOAD_SERVICE"],
    Rails.configuration.active_storage.service_configurations
  ) : ActiveStorage::Blob.service
end
