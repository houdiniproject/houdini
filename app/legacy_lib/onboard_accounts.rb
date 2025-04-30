# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "param_validation"
require "qx"

module OnboardAccounts
  def self.create_org(params)
    nonprofit_data = set_nonprofit_defaults(params["nonprofit"])
    ParamValidation.new(nonprofit_data, {
      name: {required: true},
      # email: {required: true},
      # phone: {required: true},
      city: {required: true},
      state_code: {required: true}
    })
    user_data = set_user_defaults(params["user"])
    ParamValidation.new(user_data, {
      name: {required: true},
      email: {required: true},
      password: {required: true},
      phone: {required: true}
    })
    extra_info = params["extraInfo"]

    nonprofit = Qx.insert_into(:nonprofits)
      .values(nonprofit_data).timestamps
      .returning("*")
      .execute.last

    billing_plan_id = Settings.default_bp.id
    billing_subscription = Qx.insert_into(:billing_subscriptions)
      .values({
        nonprofit_id: nonprofit["id"],
        billing_plan_id: billing_plan_id,
        status: "active"
      })
      .timestamps.execute.last

    # Create the user using the User and Role models (since we have to use Devise)
    user = User.create!(user_data)
    role = Qx.insert_into(:roles)
      .values(user_id: user.id, name: "nonprofit_admin", host_id: nonprofit["id"], host_type: "Nonprofit")
      .timestamps
      .execute.last

    delay.send_onboard_email(nonprofit, nonprofit_data, user_data, extra_info)

    {
      nonprofit: nonprofit,
      user: user,
      role: role,
      billing_subscription: billing_subscription
    }
  end

  ### ethis is a one time method in order to add a user without testing for the method. Do not use this long term
  def self.create_org_with_user(params, user = nil)
    nonprofit_data = set_nonprofit_defaults(params["nonprofit"])
    ParamValidation.new(nonprofit_data, {
      name: {required: true},
      # email: {required: true},
      # phone: {required: true},
      city: {required: true},
      state_code: {required: true}
    })
    if !user
      user_data = set_user_defaults(params["user"])
      ParamValidation.new(user_data, {
        name: {required: true},
        email: {required: true},
        password: {required: true},
        phone: {required: true}
      })
    end
    extra_info = params["extraInfo"]

    nonprofit = Qx.insert_into(:nonprofits)
      .values(nonprofit_data).timestamps
      .returning("*")
      .execute.last
    # Create a billing subscription for the 6% fee tier
    billing_plan_id = Settings.default_bp.id
    billing_subscription = Qx.insert_into(:billing_subscriptions)
      .values({
        nonprofit_id: nonprofit["id"],
        billing_plan_id: billing_plan_id,
        status: "active"
      })
      .timestamps.execute.last

    # Create the user using the User and Role models (since we have to use Devise)
    user = (!user) ? User.create!(user_data) : user
    role = Qx.insert_into(:roles)
      .values(user_id: user.id, name: "nonprofit_admin", host_id: nonprofit["id"], host_type: "Nonprofit")
      .timestamps
      .execute.last

    delay.send_onboard_email(nonprofit, nonprofit_data, user_data, extra_info)

    {
      nonprofit: nonprofit,
      user: user,
      role: role,
      billing_subscription: billing_subscription
    }
  end

  def self.set_nonprofit_defaults(data)
    data.merge({
      published: true,
      vetted: Settings.nonprofits_must_be_vetted ? false : true,
      statement: data[:name][0..16],
      city_slug: Format::Url.convert_to_slug(data[:city]),
      state_code_slug: Format::Url.convert_to_slug(data[:state_code]),
      slug: Format::Url.convert_to_slug(data[:name])
    })
  end

  def self.set_user_defaults(data)
    data
  end

  # np is the created nonprofit row in the database
  # nonprofit_data is the data sent from the onboarding form, and may include extra stuff not in the db
  # user_data and extra_info are additional data hashes sent from the onboarding form
  def self.send_onboard_email(np, nonprofit_data, user_data, extra_info)
    # Send the welcome email to the nonprofit
    NonprofitMailer.welcome(np["id"]).deliver
    # Send an email notifying people internal folks of the new nonporfit, with the above info and extra_info
    to_emails = ["support@commitchange.com"]
    message = %(
      New signup on CommitChange for an organization with the name "#{np["name"]}"
      Location: #{np["city"]} #{np["state_code"]}, #{np["zip_code"]}
      Org Email: #{nonprofit_data["email"]}
      Org Phone: #{nonprofit_data["phone"]}
      User Email: #{user_data["email"]}
      User Name: #{user_data["name"]}
      User Phone: #{user_data["phone"]}
      Entity Type: #{extra_info["entity_type"]}
      How they heard about us: #{extra_info["how_they_heard"]}
      What they want to use: #{["use_donations", "use_crm", "use_campaigns", "use_events"].select { |x| extra_info[x] == "on" }.join(", ")}
    )
    subject = "New Account Signup: #{np["name"]}"
    GenericMailer.generic_mail("support@commitchange.com", "CC Bot", message, subject, to_emails, "").deliver
  end
end
