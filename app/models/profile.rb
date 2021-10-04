# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class Profile < ApplicationRecord
  include Image::AttachmentExtensions
  # :registered, # bool
  # :mini_bio,
  # :first_name, # str
  # :last_name, # str
  # :name,
  # :phone, # str
  # :address, # str
  # :email, # str
  # :city, # str
  # :state_code, # str (eg. CA)
  # :zip_code, # str
  # :privacy_settings, # text [str]: XXX deprecated
  # :picture, # str: either their social network pic or a stored pic on S3
  # :anonymous, # bool: negates all privacy_settings
  # :city_state,
  # :user_id

  validates :email, format: { with: Email::Regex }, allow_blank: true

  attr_accessor :email, :city_state

  serialize :privacy_settings, Array

  has_one_attached :picture
  has_one_attached_with_sizes(:picture, {normal: 150, medium:100, tiny: 50})

  belongs_to :user
  has_many :activities # Activities this profile has created
  has_many :supporters
  has_many :donations
  has_many :campaigns
  has_many :events
  has_many :recurring_donations
  has_many :comments, as: :host, dependent: :destroy
  has_many :nonprofits, through: :supporters
  has_many :activities, dependent: :destroy
  #  has_one :card, as: :holder

  # accepts_nested_attributes_for :card

  scope :non_anon, -> { where(anonymous: [nil, false]) }

  before_validation(on: :create) do
    set_defaults
    self
  end

  def set_defaults
    self.name    ||= user.name    if user
    self.email   ||= user.email   if user
    picture.attach(io: File.open(Houdini.defaults.image.profile), 
        filename: "profile-image.png") unless self.picture.attached?
    if self.name.blank? && first_name.present? && last_name.present?
      self.name ||= first_name + ' ' + last_name
    end
  end

  # Queries

  def recent_donations(npo_id)
    donations.valid.order('created_at').where(nonprofit_id: npo_id).take(10)
  end

  # Attrs

  def total_given_to(nonprofit)
    donations.valid.where(nonprofit_id: nonprofit.id).pluck(:amount).sum
  end

  def monthly_giving(nonprofit_id)
    donations.where(nonprofit_id: nonprofit_id).map(&:amount).sum
  end

  def monthly_total_giving
    donations.map(&:amount).sum
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def supporter_name
    self.name.blank? ? 'A Supporter' : self.name
  end

  def get_profile_picture(size = :normal)
    # Can be, in order of precedence: your uploaded photo, facebook picture, or
    # default image
    if user.picture
      return user.get_picture(size)
    else
      return picture_url(size)
    end

    # Either does not want photo shown or has none uploaded.
    Houdini.defaults.image.profile
  end

  def url
    Rails.application.routes.url_helpers.profile_path(self)
  end

  # Cache setters

  def set_caches!
    self.total_raised = donations.pluck(:amount).sum
    self.total_recurring = recurring_donations.active.pluck(:amount).sum
    save!
  end
end
