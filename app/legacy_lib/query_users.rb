# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later

module QueryUsers
  # Return all the nonprofit user emails for a given email notification setting
  # for notification_type in ['payments', 'campaigns', 'events', 'payouts', 'recurring_donations']
  def self.nonprofit_user_emails(np_id, notification_type)
    raise ArgumentError.new("Invalid notification type") unless QueryEmailSettings::Settings.include?(notification_type)
    Qx.select("users.email")
      .from("users")
      .join("roles", "roles.user_id=users.id")
      .add_join("nonprofits", "roles.host_id=nonprofits.id AND roles.host_type='Nonprofit'")
      .add_left_join("email_settings", "email_settings.user_id=users.id")
      .where("email_settings.user_id IS NULL OR email_settings.#{notification_type}=TRUE")
      .and_where("nonprofits.id=$id", id: np_id)
      .group_by("users.email")
      .execute.map { |h| h["email"] }
  end

  # Return all nonprofit emails regardless of email settings
  def self.all_nonprofit_user_emails(np_id, roles = [:nonprofit_admin, :nonprofit_user])
    Qx.select("users.email").from("users")
      .join("roles", "roles.user_id = users.id")
      .add_join("nonprofits", "nonprofits.id = roles.host_id AND roles.host_type='Nonprofit'")
      .where("nonprofits.id=$id", id: np_id)
      .and_where("roles.name IN ($names)", names: roles)
      .execute.map { |h| h["email"] }
  end

  # Return an array of email address strings for all users with role of 'super_admin'
  def self.super_admin_emails
    Qx.select("users.email").from("users")
      .join("roles", "roles.user_id=users.id AND roles.name='super_admin'")
      .ex.map { |h| h["email"] }
  end
end
