# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE

module QueryActivities
  def self.for_timeline(nonprofit_id, supporter_id)
    Qx.select("activities.*")
      .from(:activities)
      .where("activities.supporter_id = #{supporter_id.to_i} AND activities.nonprofit_id = #{nonprofit_id.to_i}")
      .order_by("activities.date DESC")
      .execute
  end
end
