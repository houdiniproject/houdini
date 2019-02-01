# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class User < ApplicationRecord

	attr_accessible \
		:email, # str: balidated with Devise
		:password, # str: hashed with bcrypt
    :phone, # str
		:location,
		:city,
		:state_code,
		:password_confirmation, # accessor: used on registration
		:remember_me, # bool: don't sign user out for a while
		:provider, # str: OAuth provider
		:uid, # str: OAuth user ID
		:pending_password, # bool: User registered with oauth and did not set a password
		:name, # str: created with oauth
		:auto_generated, # bool: flag whether a password was auto-generated for this account
		:referer, # str: ID of the user who referred this account
		:latitude,
		:longitude,
		:reset_password_token,
		:reset_password_sent_at,
		:picture, # str: url for fb or twitter pic
		:current_password, # accessor: for updating pass
		:profile_attributes,
    :phone

	geocoded_by :location

	devise :async, :database_authenticatable, :registerable, :confirmable, :recoverable, :rememberable, :trackable, :validatable

	attr_accessor :offsite_donation_id, :current_password

	validates :email,
		presence: true,
		uniqueness: {case_sensitive: false},
		format: {with: Email::Regex}

	has_many :donations, through: :profile
	has_many :roles,     dependent: :destroy
	has_one  :profile,   dependent: :destroy
	has_many :imports
  has_many :email_settings

	accepts_nested_attributes_for :profile

	before_validation(on: :create) do
		self.password = Devise.friendly_token.first(8) if self.auto_generated
		self.build_profile if self.profile.nil?
		self
	end

  # This creates the user in the normal way, but also sends the devise email confirmation email, which we don't want to send to np admins or anyone else
  def self.register_donor!(params)
    u = User.create!(params)
    u.send_confirmation_instructions
    return u
	end

  def self.find_or_create_with_email(em)
    user = self.where("lower(email) = ?", em.downcase).first
    return user if user.present?
    User.create!(email: em, auto_generated: true)
  end

	def profile_picture(size)
		 self.profile.picture_url(size)
	end


	# Required by Devise for Omniauth
	# https://github.com/plataformatec/devise/wiki/OmniAuth:-Overview
	def self.new_with_session(params, session)
		super.tap do |user|
			if data = session['devise.facebook_data'] && session['devise.facebook_data']['extra']['raw_info']
				user.email = data['email'] if user.email.blank?
			end
		end
	end

	# Don't require confirmation for new users -- they can still donate without confirmation
	# https://github.com/plataformatec/devise/wiki/How-To:-Override-confirmations-so-users-can-pick-their-own-passwords-as-part-of-confirmation-activation
	def confirmation_required?
		false
	end

	def as_json(options={})
		h = super(options)
		h[:unconfirmed_email] = self.unconfirmed_email
		h[:confirmed] = self.confirmed?
		h[:profile] = self.profile.as_json
		h
	end

  # This is useful for manually generating a Devise user confirmation token so that we can get the confirmation URL with the correct token from anywhere
  def make_confirmation_token!
    raw, db = Devise.token_generator.generate(User, :confirmation_token)
    self.confirmation_token = db
    self.confirmation_sent_at = Time.now
    self.save!
    return raw
  end

	def geocode!
		#self.geocode
		#self.save
	end

end
