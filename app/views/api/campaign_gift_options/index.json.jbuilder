# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
json.array!(
	@campaign_gift_options,
	partial: '/api/campaign_gift_options/campaign_gift_option',
	as: 'campaign_gift_option'
)
