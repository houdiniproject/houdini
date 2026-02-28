# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
module QueryEventOrganizer
  def self.with_event(event_id)
    Qx.select(
      "coalesce(profiles.name, nonprofits.name) AS name",
      "coalesce(users.email, nonprofits.email) AS email"
    )
      .from(:events)
      .left_join(:profiles, "profiles.id=events.profile_id")
      .add_left_join(:users, "profiles.user_id=users.id")
      .add_join(:nonprofits, "events.nonprofit_id=nonprofits.id")
      .where("events.id=$id", id: event_id)
      .execute.first
  end
end
