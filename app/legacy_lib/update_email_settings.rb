# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module UpdateEmailSettings
  def self.save(np_id, user_id, params)
    es = Psql.execute(
      Qexpr.new.select(:id).from(:email_settings)
      .where("nonprofit_id=$id", id: np_id.to_i)
      .where("user_id=$id", id: user_id)
    ).first
    if es.nil?
      es = Psql.execute(Qexpr.new.insert("email_settings", [{nonprofit_id: np_id, user_id: user_id}], {no_timestamps: true})).first
    end
    Psql.execute(
      Qexpr.new.update(:email_settings, params)
      .where("id=$id", id: es["id"])
      .returning("*")
    ).first
  end
end
