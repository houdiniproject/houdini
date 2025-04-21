# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
namespace :seed do
  task np: :environment do
    ActiveRecord::Base.transaction do
      supers = Role.super_admins.includes(:user).map(&:user)
      n = Nonprofit.register(supers.last, name: "Testify #{rand(0..100)}", city: "Albuquerque", state_code: "NM")
      n.verification_status = "verified"
      n.vetted = true
      n.create_billing_subscription(billing_plan: BillingPlan.where(tier: 2).last)
      n.save!
      supers.each { |user| user.roles.create(name: :nonprofit_admin, host: n) }
      puts "New test nonprofit id: #{n.id}"
    end
  end
end
