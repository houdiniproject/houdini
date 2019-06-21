# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class Event < ApplicationRecord

	#TODO
	# attr_accessible \
	# 	:deleted, #bool for soft-delete
	# 	:name, # str
	# 	:tagline, # str
	# 	:summary, # text
	# 	:body, # text (html)
    # :end_datetime,
    # :start_datetime,
	# 	:latitude, # float
	# 	:longitude, # float
	# 	:location, # str
	# 	:city, # str
	# 	:state_code, # str
	# 	:address, # str
	# 	:zip_code, # str
	# 	:main_image, # str
	# 	:remove_main_image, # for carrierwave
	# 	:background_image, # str
	# 	:remove_background_image, # bool carrierwave
	# 	:published, # bool
	# 	:slug, # str
	# 	:directions, # text
	# 	:venue_name, # str
	# 	:profile_id, # creator
	# 	:ticket_levels_attributes,
	# 	:show_total_raised, # bool
	# 	:show_total_count, # bool
	# 	:hide_activity_feed, # bool
	# 	:nonprofit_id, # host
	# 	:hide_title,  # bool
    # :organizer_email, # string
    # :receipt_message # text

	validates :name, :presence => true
  validates :end_datetime, :presence => true
  validates :start_datetime, :presence => true
	validates :address, :presence => true
	validates :city, :presence => true
	validates :state_code, :presence => true
	validates :slug, :presence => true, uniqueness: {scope: :nonprofit_id, message: 'You already have an event with that URL'}
	validates :nonprofit_id, :presence => true
	validates :profile_id, :presence => true

	belongs_to :nonprofit
	belongs_to :profile
	has_many :donations
	has_many :charges, through: :tickets
	has_many :supporters, through: :donations
	has_many :recurring_donations
	has_many :ticket_levels, :dependent => :destroy
  has_many :event_discounts, dependent: :destroy
	has_many :tickets
	has_many :payments, through: :tickets
	has_many :roles,           as: :host, dependent: :destroy
	has_many :comments,        as: :host, dependent: :destroy
	has_many :activities,      as: :host, dependent: :destroy


	geocoded_by :full_address

	accepts_nested_attributes_for :ticket_levels, :allow_destroy => true

	mount_uploader :main_image, EventMainImageUploader
	mount_uploader :background_image, EventBackgroundImageUploader

	scope :not_deleted, -> {where(deleted: [nil,false])}
  scope :deleted, -> {where(deleted: true)}
	scope :published, -> {where(:published => true)}
  scope :upcoming, -> {where("start_datetime >= ?", Date.today).published}
  scope :past, -> {where("end_datetime < ?", Date.today).published}
	scope :unpublished, -> {where("published != ?", true)}

  validates :slug, uniqueness: {scope: :nonprofit_id, message: 'You already have a campaign with that name.'}

	before_validation(on: :create) do
		unless self.slug
			self.slug = Format::Url.convert_to_slug(name)
		end
		self.published = false if self.published.nil?
		self.total_raised ||= 0
    self
	end

	after_validation :geocode

	after_create do
		user = self.profile.user
		Role.create(name: :event_editor, user_id: user.id, host: self)
		EventMailer.delay.creation_followup(self)
		self
	end

	def url
		"#{self.nonprofit.url}/events/#{self.slug}"
	end

  def full_address
    Format::Address.full_address(self.address, self.city, self.state_code, self.zip_code)
  end

end
