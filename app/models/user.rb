# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class User < ApplicationRecord
  # :email, # str: balidated with Devise
  # :password, # str: hashed with bcrypt
  # :phone, # str
  # :location,
  # :city,
  # :state_code,
  # :password_confirmation, # accessor: used on registration
  # :remember_me, # bool: don't sign user out for a while
  # :provider, # str: OAuth provider
  # :uid, # str: OAuth user ID
  # :pending_password, # bool: User registered with oauth and did not set a password
  # :name, # str: created with oauth
  # :auto_generated, # bool: flag whether a password was auto-generated for this account
  # :referer, # str: ID of the user who referred this account
  # :reset_password_token,
  # :reset_password_sent_at,
  # :picture, # str: url for fb or twitter pic
  # :current_password, # accessor: for updating pass
  # :profile_attributes,
  # :phone

  devise :async, :database_authenticatable, :registerable, :confirmable, :recoverable, :rememberable, :trackable, :validatable

  attr_accessor :offsite_donation_id, :current_password

  validates :email,
    presence: true,
    uniqueness: {case_sensitive: false},
    format: {with: Email::Regex}

  has_many :donations, through: :profile
  has_many :roles, dependent: :destroy
  has_one :profile, dependent: :destroy
  has_many :imports
  has_many :email_settings

  accepts_nested_attributes_for :profile

  before_validation(on: :create) do
    self.password = Devise.friendly_token.first(8) if auto_generated
    build_profile if profile.nil?
    self
  end

  #
  # Is this user a super_admin?
  #
  # @return [boolean] True if the user is, false otherwise
  #
  def super_admin?
    roles.super_admins.any?
  end

  # This creates the user in the normal way, but also sends the devise email confirmation email, which we don't want to send to np admins or anyone else
  def self.register_donor!(params)
    u = User.create!(params)
    u.send_confirmation_instructions
    u
  end

  def self.find_or_create_with_email(em)
    user = where("lower(email) = ?", em.downcase).first
    return user if user.present?

    User.create!(email: em, auto_generated: true)
  end

  def profile_picture(size)
    profile.picture_url(size)
  end

  # Required by Devise for Omniauth
  # https://github.com/plataformatec/devise/wiki/OmniAuth:-Overview
  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
        user.email = data["email"] if user.email.blank?
      end
    end
  end

  # Don't require confirmation for new users -- they can still donate without confirmation
  # https://github.com/plataformatec/devise/wiki/How-To:-Override-confirmations-so-users-can-pick-their-own-passwords-as-part-of-confirmation-activation
  def confirmation_required?
    false
  end

  # This is useful for manually generating a Devise user confirmation token so that we can get the confirmation URL with the correct token from anywhere
  def make_confirmation_token!
    raw, db = Devise.token_generator.generate(User, :confirmation_token)
    self.confirmation_token = db
    self.confirmation_sent_at = Time.now
    save!
    raw
  end

  def to_builder(*expand)
    Jbuilder.new do |json|
      json.object "user"
      json.id id
    end
  end
end
