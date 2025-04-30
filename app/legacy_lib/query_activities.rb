# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "qx"

module QueryActivities
  def self.for_timeline(nonprofit_id, supporter_id)
    Qx.select("activities.*")
      .from(:activities)
      .where("activities.supporter_id = #{supporter_id.to_i} AND activities.nonprofit_id = #{nonprofit_id.to_i}")
      .order_by("activities.date DESC")
      .execute
  end
end
