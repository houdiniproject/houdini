# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later

module StripeAccount

  # Returns the stripe account ID string
  def self.find_or_create(nonprofit_id)
		ParamValidation.new({:nonprofit_id => nonprofit_id}, {:nonprofit_id => {:required=> true, :is_integer => true}})
		begin
    	np = Nonprofit.find(nonprofit_id)
		rescue => e
			raise ParamValidation::ValidationError.new("#{nonprofit_id} is not a valid nonprofit", {:key => :nonprofit_id})
		end

		if !np['stripe_account_id']
      return create(np)
    else
      return np['stripe_account_id']
    end
  end

  # np should be a hash with string keys
  def self.create(np)
		ParamValidation.new({:np => np}, {:np => {:required=> true, :is_a => Nonprofit}})
		params = {
				type: 'custom',
				email: np['email'].present? ? np['email'] : np.roles.nonprofit_admins.order('created_at ASC').first.user.email,
				business_type: 'company',
				company: {
						name: np['name'],
						address: {
								city: np['city'],
								state: np['state_code'],
								postal_code: np['zip_code'],
								country: 'US'
						}
				},
				settings: {
					payouts: {
						schedule: {
							interval: 'manual' 
						}
					}
				},
				requested_capabilities: [
					'legacy_payments',
				  ],
				business_profile: {
					product_description: 'Nonprofit donations'
				}
		}

		if np['website'] && np['website'] =~ URI::regexp
			params[:business_profile][:url] = np['website']
		end

		acct = Stripe::Account.create(params, {stripe_version: '2019-09-09' })
    Qx.update(:nonprofits).set(stripe_account_id: acct.id).where(id: np['id']).execute
    NonprofitMailer.delay.setup_verification(np['id'])
    return acct.id
	end
end
