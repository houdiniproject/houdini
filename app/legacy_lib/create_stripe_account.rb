# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "stripe"

module CreateStripeAccount
  def self.for_nonprofit(user, params)
    fst_name, lst_name = Format::Name.split_full(user&.profile&.name)
    Stripe::Account.create(
      managed: true,
      email: params[:email],
      business_name: params[:name],
      business_url: params[:website],
      legal_entity: {
        type: "company",
        address: {
          line1: params[:address],
          city: params[:city],
          state: params[:state_code],
          postal_code: params[:zip_code],
          country: "US"
        },
        business_name: params[:name],
        business_tax_id: params[:ein],
        first_name: fst_name,
        last_name: lst_name
      },
      product_description: "Nonprofit donations",
      tos_acceptance: {
        date: Time.current.to_i,
        ip: user.current_sign_in_ip
      },
      transfer_schedule: {interval: "manual"}
    )
  end
end
