# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module QueryRoles
  def self.user_has_role?(user_id, role_names, host_id = nil)
    expr = Qx.select("COUNT(roles)").from(:roles)
      .where("name IN ($names)", names: Array(role_names))
      .and_where(user_id: user_id)
    expr = expr.and_where(host_id: host_id) if host_id
    expr.execute.first["count"] > 0
  end

  # Get host tables -- host can be nonprofit, campaign, event
  def self.host_ids(user_id, role_names)
    Qx.select("host_id").from(:roles)
      .where(user_id: user_id)
      .and_where("roles.name IN ($names)", names: role_names)
      .execute.map { |h| h["host_id"] }
  end

  def self.is_nonprofit_user?(user_id, np_id)
    user_has_role?(user_id, [:nonprofit_admin, :nonprofit_associate], np_id)
  end

  def self.is_authorized_for_nonprofit?(user_id, np_id)
    user_has_role?(user_id, [:super_admin]) || is_nonprofit_user?(user_id, np_id)
  end
end
