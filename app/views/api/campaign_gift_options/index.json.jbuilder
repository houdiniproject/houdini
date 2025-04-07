# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
json.data(
  @campaign_gift_options,
  partial: "/api/campaign_gift_options/campaign_gift_option",
  as: "campaign_gift_option"
)

json.current_page @campaign_gift_options.current_page
json.first_page @campaign_gift_options.first_page?
json.last_page @campaign_gift_options.last_page?
json.requested_size @campaign_gift_options.limit_value
json.total_count @campaign_gift_options.total_count
