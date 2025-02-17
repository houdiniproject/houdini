# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE

shared_examples "json results for ticket_level_with_event_non_admin__order_3__not_deleted" do
  it {
    is_expected.to include("object" => "ticket_level")
  }

  it {
    is_expected.to include("id" => ticket_level.id)
  }

  it {
    is_expected.to include("name" => "ticket level name")
  }

  it {
    is_expected.to include("nonprofit" => nonprofit.id)
  }

  it {
    is_expected.to include("event" => event.id)
  }

  it {
    is_expected.to include("deleted" => false)
  }

  it {
    is_expected.to include("description" => "desc ticket")
  }

  it {
    is_expected.to include("available_to" => "everyone")
  }

  it {
    is_expected.to include("order" => 3)
  }

  it {
    is_expected.to include("limit" => 2)
  }

  it {
    is_expected.to include("amount" => {"cents" => 200, "currency" => nonprofit.currency})
  }

  it {
    is_expected.to include("url" =>
      base_url(nonprofit.id, event.id, ticket_level.id))
  }
end
