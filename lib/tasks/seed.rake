# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
namespace :seed do
  task np: :environment do
    ActiveRecord::Base.transaction do
      supers = Role.super_admins.includes(:user).map { |r| r.user }
      n = Nonprofit.register(supers.last, name: "Testify #{rand(0..100)}", city: "Albuquerque", state_code: "NM")
      n.vetted = true
      n.create_billing_subscription({billing_plan: BillingPlan.last})
      n.save!
      supers.each { |user| user.roles.create(name: :nonprofit_admin, host: n) }
      puts "New test nonprofit id: #{n.id}"
    end
  end
end
