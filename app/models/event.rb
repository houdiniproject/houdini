# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class Event < ApplicationRecord
  include Image::AttachmentExtensions
  include Model::Jbuilder

  # :deleted, #bool for soft-delete
  # :name, # str
  # :tagline, # str
  # :summary, # text
  # :body, # text (html)
  # :end_datetime,
  # :start_datetime,
  # :location, # str
  # :city, # str
  # :state_code, # str
  # :address, # str
  # :zip_code, # str
  # :main_image, # str
  # :remove_main_image, # for carrierwave
  # :background_image, # str
  # :remove_background_image, # bool carrierwave
  # :published, # bool
  # :slug, # str
  # :directions, # text
  # :venue_name, # str
  # :profile_id, # creator
  # :ticket_levels_attributes,
  # :show_total_raised, # bool
  # :show_total_count, # bool
  # :hide_activity_feed, # bool
  # :nonprofit_id, # host
  # :hide_title,  # bool
  # :organizer_email, # string
  # :receipt_message # text

  validates :name, presence: true
  validates :end_datetime, presence: true
  validates :start_datetime, presence: true
  validates :address, presence: true
  validates :city, presence: true
  validates :state_code, presence: true
  validates :slug, presence: true, uniqueness: {scope: :nonprofit_id, message: "You already have an event with that URL"}
  validates :nonprofit_id, presence: true
  validates :profile_id, presence: true

  belongs_to :nonprofit
  belongs_to :profile
  has_many :donations
  has_many :charges, through: :tickets
  has_many :supporters, through: :donations
  has_many :recurring_donations
  has_many :ticket_levels, dependent: :destroy
  has_many :event_discounts, dependent: :destroy
  has_many :tickets
  has_many :payments, through: :tickets
  has_many :roles, as: :host, dependent: :destroy
  has_many :activities, as: :host, dependent: :destroy

  accepts_nested_attributes_for :ticket_levels, allow_destroy: true
  has_one_attached :main_image
  has_one_attached :background_image

  has_one_attached_with_sizes :main_image, {normal: 400, thumb: 100}
  has_one_attached_with_sizes :background_image, {normal: [1000, 600]}

  has_one_attached_with_default(:main_image, Houdini.defaults.image.profile,
    filename: "main_image_#{SecureRandom.uuid}#{Pathname.new(Houdini.defaults.image.profile).extname}")

  has_one_attached_with_default(:background_image, Houdini.defaults.image.campaign,
    filename: "background_image_#{SecureRandom.uuid}#{Pathname.new(Houdini.defaults.image.campaign).extname}")

  scope :not_deleted, -> { where(deleted: [nil, false]) }
  scope :deleted, -> { where(deleted: true) }
  scope :published, -> { where(published: true) }
  scope :upcoming, -> { where("start_datetime >= ?", Date.today).published }
  scope :past, -> { where("end_datetime < ?", Date.today).published }
  scope :unpublished, -> { where.not(published: true) }

  validates :slug, uniqueness: {scope: :nonprofit_id, message: "You already have a campaign with that name."}

  before_validation(on: :create) do
    self.slug = Format::Url.convert_to_slug(name) unless slug
    self.published = false if published.nil?
    self.total_raised ||= 0
    self
  end

  after_create do
    user = profile.user
    Role.create(name: :event_editor, user_id: user.id, host: self)
    EventCreateJob.perform_later self
    self
  end

  def to_builder(*expand)
    init_builder(*expand) do |json|
      json.call(self, :name)
      json.add_builder_expansion :nonprofit
    end
  end

  def url
    "#{nonprofit.url}/events/#{slug}"
  end

  def full_address
    Format::Address.full_address(address, city, state_code, zip_code)
  end
end
