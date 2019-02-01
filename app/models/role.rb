# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class Role < ApplicationRecord

	Names = [
		:super_admin,          # global access 
		:super_associate,      # global access to everything except bank acct info  
		:nonprofit_admin,      # npo scoped access to everything
		:nonprofit_associate,  # npo scoped access to everything except bank acct info
		:campaign_editor,      # fundraising tools, without dashboard access
		:event_editor          # //
	]

	attr_accessible \
		:name,
		:user_id, :user,
		:host, :host_id, :host_type # nil, "Nonprofit", "Campaign", "Event"

	belongs_to :user
	belongs_to :host, polymorphic: true

	scope :super_admins, -> {where(name: :super_admin)}
	scope :super_associate, -> {where(name: :super_associate)}
	scope :nonprofit_admins, -> {where(name: :nonprofit_admin)}
	scope :nonprofit_personnel, -> {where(name: [:nonprofit_associate, :nonprofit_admin])}
	scope :campaign_editors, -> {where(name: :campaign_editor)}
	scope :event_editors, -> {where(name: :event_editor)}

	validates :user, presence: true
	validates :name, inclusion: {in: Names}
	validates :host, presence: true, unless: [:super_admin?, :super_associate?]

	def name; super.to_sym; end
	def super_admin?; name == :super_admin; end
	def super_associate?; name == :super_associate; end

	def self.create_for_nonprofit(role_name, email, nonprofit)
		user = User.find_or_create_with_email(email)
		role = Role.create(user: user, name: role_name, host: nonprofit)
		return role unless role.valid?
		if user.confirmed?
			NonprofitAdminMailer.delay.existing_invite(role)
		else
			NonprofitAdminMailer.delay.new_invite(role, user.make_confirmation_token!)
		end
		return role
	end

end

