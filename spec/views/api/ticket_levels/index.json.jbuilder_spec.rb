# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"

RSpec.describe "/api/ticket_levels/index.json.jbuilder" do
  subject(:json) do
    assign(:ticket_levels, Kaminari.paginate_array([
      ticket_level_with_event_non_admin__order_3__not_deleted
    ]).page)
    render
    JSON.parse(rendered)
  end

  def base_path(nonprofit_id, event_id, ticket_level_id)
    "/api/nonprofits/#{nonprofit_id}/events/#{event_id}/ticket_levels/#{ticket_level_id}"
  end

  def base_url(nonprofit_id, event_id, ticket_level_id)
    "http://test.host#{base_path(nonprofit_id, event_id, ticket_level_id)}"
  end

  let(:ticket_level_with_event_non_admin__order_3__not_deleted) do
    create(:ticket_level_with_event_non_admin__order_3__not_deleted)
  end

  it { expect(json["data"].count).to eq 1 }

  describe "details of the :ticket_level_with_event_non_admin__order_3__not_deleted" do
    subject do
      json["data"][0]
    end

    let(:ticket_level) { ticket_level_with_event_non_admin__order_3__not_deleted }
    let(:event) { ticket_level.event }
    let(:nonprofit) { ticket_level.nonprofit }

    include_context "json results for ticket_level_with_event_non_admin__order_3__not_deleted"
  end

  describe "paging" do
    subject(:json) do
      ticket_level_with_event_non_admin__order_3__not_deleted
      6.times do |i|
        create(
          :ticket_level_with_event_non_admin__order_3__not_deleted,
          event: ticket_level_with_event_non_admin__order_3__not_deleted.event,
          name: i
        )
      end
      assign(:ticket_levels,
        ticket_level_with_event_non_admin__order_3__not_deleted.event.ticket_levels.order("id DESC").page.per(5))
      render
      JSON.parse(rendered)
    end

    it { is_expected.to include("data" => have_attributes(count: 5)) }
    it { is_expected.to include("first_page" => true) }
    it { is_expected.to include("last_page" => false) }
    it { is_expected.to include("current_page" => 1) }
    it { is_expected.to include("requested_size" => 5) }
    it { is_expected.to include("total_count" => 7) }
  end
end
