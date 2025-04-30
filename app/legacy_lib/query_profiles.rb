# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later

module QueryProfiles
  def self.for_admin(params)
    expr = Qx.select(
      "profiles.name",
      "profiles.id",
      "profiles.created_at::date::text AS created_at",
      "users.confirmed_at AS is_confirmed",
      "users.email"
    )
      .from(:profiles)
      .add_left_join("users", "profiles.user_id=users.id")
      .order_by("profiles.created_at DESC")
      .paginate(params[:page].to_i, params[:page_length].to_i)

    if params[:search].present?
      expr = expr.where(%(
          profiles.name LIKE $search
          OR users.email LIKE $search
          OR users.name LIKE $search
        ), search: "%" + params[:search].downcase + "%")
    end

    expr.execute
  end
end
