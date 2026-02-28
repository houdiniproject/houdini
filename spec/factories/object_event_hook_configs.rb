# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
FactoryBot.define do
  factory :open_fn_config, class: "ObjectEventHookConfig" do
    webhook_service { :open_fn }
    configuration do
      {
        webhook_url: "https://www.openfn.org/inbox/my-inbox-id",
        headers: {"x-api-key": "my-secret-key"}
      }
    end
    object_event_types { ["supporter.update"] }
  end
end
