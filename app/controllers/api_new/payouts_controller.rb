# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE

# Rails 6 requires a matching controller for the `spec/views/api_new/payouts/show.json.jbuilder_spec.rb` spec
# This controller isn't currently used for anything else.
class ApiNew::PayoutsController < ApiNew::ApiController
end