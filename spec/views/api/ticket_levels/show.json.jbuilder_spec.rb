# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"

RSpec.describe "/api/ticket_levels/show.json.jbuilder" do
  def base_path(nonprofit_id, event_id, ticket_level_id)
    "/api/nonprofits/#{nonprofit_id}/events/#{event_id}/ticket_levels/#{ticket_level_id}"
  end

  def base_url(nonprofit_id, event_id, ticket_level_id)
    "http://test.host#{base_path(nonprofit_id, event_id, ticket_level_id)}"
  end

  subject(:json) do
    view.lookup_context.prefixes = view.lookup_context.prefixes.drop(2)
    assign(:ticket_level, ticket_level)
    render
    JSON.parse(rendered)
  end

  let(:event) { ticket_level.event }
  let(:nonprofit) { ticket_level.nonprofit }

  let(:ticket_level) { create(:ticket_level_with_event_non_admin__order_3__not_deleted) }

  include_context "json results for ticket_level_with_event_non_admin__order_3__not_deleted"
end
