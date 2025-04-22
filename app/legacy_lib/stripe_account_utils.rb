# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later

module StripeAccountUtils
  # Returns the stripe account ID string
  def self.find_or_create(nonprofit_id)
    ParamValidation.new({nonprofit_id: nonprofit_id}, {nonprofit_id: {required: true, is_integer: true}})
    begin
      np = Nonprofit.find(nonprofit_id)
    rescue
      raise ParamValidation::ValidationError.new("#{nonprofit_id} is not a valid nonprofit", {key: :nonprofit_id})
    end

    if !np["stripe_account_id"]
      create(np)
    else
      np["stripe_account_id"]
    end
  end

  # np should be a hash with string keys
  def self.create(np)
    ParamValidation.new({np: np}, {np: {required: true, is_a: Nonprofit}})
    params = {
      type: "custom",
      email: np["email"].present? ? np["email"] : np.roles.nonprofit_admins.order("created_at ASC").first.user.email,
      settings: {
        payouts: {
          schedule: {
            interval: "manual"
          }
        }
      },
      requested_capabilities: [
        "card_payments",
        "transfers"
      ],
      business_profile: {
        product_description: "Nonprofit donations"
      }
    }

    if np["website"] && np["website"] =~ URI::DEFAULT_PARSER.make_regexp
      params[:business_profile][:url] = np["website"]
    end
    acct = Stripe::Account.create(params, {stripe_version: "2019-09-09"})
    np = Nonprofit.find(np["id"])
    np.stripe_account_id = acct.id
    np.save!
    acct.id
  end
end
