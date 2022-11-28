# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE

ActiveRecord::Base.transaction do 

  DEFAULT_PASSWORD = '123123'

 	puts("[seeds] Loading Billing Plan")

	bp = BillingPlan.find_or_create_by(
		name: 'Default billing plan',
		amount: 0,
		percentage_fee: 0,
	)
	bp.save!

 	puts("[seeds] Loading admin user")

	system_admin = User.find_or_create_by(
		name: "Admin", 
		email: "admin@gmail.com", 
		state_code: "AZ", 
		city: "Phoenix", 
		confirmed_at: Time.now.utc
	)
	system_admin.password = DEFAULT_PASSWORD
	system_admin.save!

 	puts("[seeds] Loading nonprofit informations")
	 
	nonprofit_admin = Nonprofit.find_or_create_by(
		 name: "Admin Nonprofit",
		 email: "admin@gmail.com", 
		 state_code: "AZ", 
		 city: "Phoenix",
		)
	nonprofit_admin.user_id = system_admin.id
	nonprofit_admin.save!
	
	puts("[seeds] initial information completed successfully")
	
end