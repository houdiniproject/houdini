# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class Nonprofit < ApplicationRecord
  attr_accessor :register_np_only, :user_id, :user
  Categories = ["Public Benefit", "Human Services", "Education", "Civic Duty", "Human Rights", "Animals", "Environment", "Health", "Arts, Culture, Humanities", "International", "Children", "Religion", "LGBTQ", "Women's Rights", "Disaster Relief", "Veterans"].freeze

  include Image::AttachmentExtensions

  # :name, # str
  # :stripe_account_id, # str
  # :summary, # text: paragraph-sized organization summary
  # :tagline, # str
  # :email, # str: public organization contact email
  # :phone, # str: public org contact phone
  # :main_image, # str: url of featured image - first image in profile carousel
  # :background_image,  # str: url of large profile background
  # :remove_background_image, #bool carrierwave
  # :logo, # str: small logo image url for searching
  # :zip_code, # int
  # :website, # str: their own website url
  # :categories, # text [str]: see the constant Categories
  # :achievements, # text [str]: highlights about this org
  # :full_description, # text
  # :state_code, # str: two-letter state code (eg. CA)
  # :statement, # str: bank statement for donations towards the nonprofit
  # :city, # str
  # :slug, # str
  # :city_slug, #str
  # :state_code_slug, #str
  # :ein, # str: employee identification number
  # :published, # boolean; whether to display this profile
  # :vetted, # bool: Whether a super admin (one of CommitChange's employees) have approved this org
  # :verification_status, # str (either 'pending', 'unverified', 'escalated', 'verified' -- whether the org has submitted the identity verification form and it has been approved)
  # :timezone, # str
  # :address, # text
  # :thank_you_note, # text
  # :referrer, # str
  # :no_anon, # bool: whether to allow anonymous donations
  # :roles_attributes,
  # :brand_font, #string (lowercase key eg. 'helvetica')
  # :brand_color, #string (hex color value)
  # :hide_activity_feed, # bool
  # :tracking_script,
  # :facebook, #string (url)
  # :twitter, #string (url)
  # :youtube, #string (url)
  # :instagram, #string (url)
  # :blog, #string (url)
  # :card_failure_message_top, # text
  # :card_failure_message_bottom, # text
  # :autocomplete_supporter_address # boolean

  has_many :payouts
  has_many :charges
  has_many :refunds, through: :charges
  has_many :donations
  has_many :recurring_donations
  has_many :payments
  has_many :supporters, dependent: :destroy
  has_many :transactions, through: :supporters
  has_many :supporter_notes, through: :supporters
  has_many :profiles, through: :donations
  has_many :campaigns, dependent: :destroy
  has_many :events, dependent: :destroy
  has_many :object_event_hook_configs, dependent: :destroy do
    def for_type(type)
      self.select do |config|
        config.object_event_types.include? type
      end
    end
  end
  has_many :tickets, through: :events
  has_many :roles, as: :host, dependent: :destroy
  has_many :users, through: :roles
  has_many :admins, -> { where("name = ?", :nonprofit_admin) }, through: :roles, class_name: "User", autosave: true, source: :user do
    def build_admin(**kwargs)
      build(kwargs.merge({name: :nonprofit_admin}))
    end
  end
  has_many :custom_field_definitions, dependent: :destroy
  has_many :tag_definitions, dependent: :destroy

  has_many :activities, as: :host, dependent: :destroy
  has_many :imports
  has_many :email_settings

  has_one :bank_account, -> { where("COALESCE(deleted, false) = false") },
    dependent: :destroy
  has_one :billing_subscription, dependent: :destroy
  has_one :billing_plan, through: :billing_subscription
  has_one :miscellaneous_np_info

  validates_associated :admins, on: :create
  validates :name, presence: true
  validates :city, presence: true
  validates :state_code, presence: true
  validates :email, format: {with: Email::Regex, allow_nil: true}
  validates :slug, presence: true
  validates :slug, uniqueness: {scope: %i[city_slug state_code_slug]}
  validates :website, url: {schemes: ["http", "https"], public_suffix: true, no_local: true}, allow_nil: true

  validates :user_id, presence: {on: :create, unless: -> { register_np_only }}
  validate :user_is_valid, on: :create, unless: -> { register_np_only }
  validate :user_registerable_as_admin, on: :create, unless: -> { register_np_only }
  validate :timezone_is_valid
  validate :state_is_valid

  scope :vetted, -> { where(vetted: true) }
  scope :identity_verified, -> { where(verification_status: "verified") }
  scope :published, -> { where(published: true) }

  has_one_attached :main_image
  has_one_attached :background_image
  has_one_attached :logo

  # way too wordy
  has_one_attached_with_sizes(:logo, {small: 30, normal: 100, large: 180})
  has_one_attached_with_sizes(:background_image, {normal: [1000, 600]})
  has_one_attached_with_sizes(:main_image, {nonprofit_carousel: [590, 338], thumb: [188, 120], thumb_explore: [100, 100]})

  has_one_attached_with_default(:logo, Houdini.defaults.image.profile,
    filename: "logo_#{SecureRandom.uuid}#{Pathname.new(Houdini.defaults.image.profile).extname}")
  has_one_attached_with_default(:background_image, Houdini.defaults.image.nonprofit,
    filename: "background_image_#{SecureRandom.uuid}#{Pathname.new(Houdini.defaults.image.nonprofit).extname}")
  has_one_attached_with_default(:main_image, Houdini.defaults.image.profile,
    filename: "main_image_#{SecureRandom.uuid}#{Pathname.new(Houdini.defaults.image.profile).extname}")

  before_validation(on: :create) do
    set_slugs
    set_user
    add_billing_subscription
    add_scheme_to_website
    self
  end

  after_create :build_admin_role, unless: -> { register_np_only }

  # Register (create) a nonprofit with an initial admin
  def self.register(user, params)
    np = create ConstructNonprofit.construct(user, params)
    Role.create(user: user, name: "nonprofit_admin", host: np) if np.valid?
    np
  end

  def nonprofit_personnel_emails
    roles.nonprofit_personnel.joins(:user).pluck("users.email")
  end

  def total_recurring
    recurring_donations.active.sum(:amount)
  end

  def as_json(options = {})
    h = super
    h[:url] = url
    h
  end

  def state_is_valid
    errors.add(:state_code, "must be a US two-letter state code") unless ISO3166::Country[:US].subdivisions.has_key? state_code&.upcase
  end

  def url
    "/#{state_code_slug}/#{city_slug}/#{slug}"
  end

  def set_slugs
    self.slug = Format::Url.convert_to_slug name unless slug
    self.city_slug = Format::Url.convert_to_slug city unless city_slug

    unless state_code_slug
      self.state_code_slug = Format::Url.convert_to_slug state_code
    end
    if Nonprofit.where(slug: slug, city_slug: city_slug, state_code_slug: state_code_slug).any?
      correct_nonunique_slug
    end
    self
  end

  def correct_nonunique_slug
    slug = SlugNonprofitNamingAlgorithm.new(state_code_slug, city_slug).create_copy_name(self.slug)
    self.slug = slug
  rescue UnableToCreateNameCopyError
    errors.add(:slug, "could not be created.")
  end

  def set_user
    if user_id && User.where(id: user_id).any?
      @user = User.find(user_id)
    end
    self
  end

  def full_address
    Format::Address.full_address(address, city, state_code)
  end

  def total_raised
    QueryPayments.get_payout_totals(QueryPayments.ids_for_payout(id))["net_amount"]
  end

  def can_make_payouts
    vetted &&
      verification_status == "verified" &&
      bank_account &&
      !bank_account.pending_verification
  end

  def currency_symbol
    Houdini.intl.all_currencies[currency.downcase.to_sym][:symbol]
  end

  concerning :JBuilder do
    include Model::Jbuilder

    def to_builder(*expand)
      init_builder(*expand) do |json|
        json.call(self, :id, :name)
      end
    end
  end

  private

  def build_admin_role
    role = user.roles.build(host: self, name: "nonprofit_admin")
    role.save!
  end

  def add_billing_subscription
    billing_plan = BillingPlan.find(Houdini.default_bp)
    build_billing_subscription(billing_plan: billing_plan, status: "active")
  end

  def add_scheme_to_website
    website = self.website
    begin
      uri = URI.parse(website)
      host = uri && uri.host
      scheme = uri && uri.scheme

      host && scheme
      valid_website = website && website.include?(".")

      self.website = "http://" + website if scheme.blank? && valid_website
    rescue URI::InvalidURIError => e
      e
    end
  end

  def user_registerable_as_admin
    if user && user.roles.nonprofit_admins.any?
      errors.add(:user_id, "cannot already be an admin for a nonprofit.")
    end
  end

  def user_is_valid
    (user && user.is_a?(User)) || errors.add(:user_id, "is not a valid user")
  end

  def timezone_is_valid
    timezone.blank? or
      ActiveSupport::TimeZone.all.map { |t| t.tzinfo.name }.include?(timezone) or
      errors.add(:timezone, "is not a valid timezone")
  end
end
