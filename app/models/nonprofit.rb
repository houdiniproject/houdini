# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class Nonprofit < ApplicationRecord
  include Model::Houidable
  setup_houid :np, :houid

  Categories = ["Public Benefit", "Human Services", "Education", "Civic Duty", "Human Rights", "Animals", "Environment", "Health", "Arts, Culture, Humanities", "International", "Children", "Religion", "LGBTQ", "Women's Rights", "Disaster Relief", "Veterans"]

  attr_accessible \
    :name, # str
    :stripe_account_id, # str
    :summary, # text: paragraph-sized organization summary
    :tagline, # str
    :email, # str: public organization contact email
    :phone, # str: public org contact phone
    :main_image, # str: url of featured image - first image in profile carousel
    :background_image,  # str: url of large profile background
    :remove_background_image, # bool carrierwave
    :logo, # str: small logo image url for searching
    :zip_code, # int
    :website, # str: their own website url
    :categories, # text [str]: see the constant Categories
    :achievements, # text [str]: highlights about this org
    :full_description, # text
    :state_code, # str: two-letter state code (eg. CA)
    :statement, # str: bank statement for donations towards the nonprofit
    :city, # str
    :slug, # str
    :city_slug, # str
    :state_code_slug, # str
    :ein, # str: employee identification number
    :published, # boolean; whether to display this profile
    :vetted, # bool: Whether a super admin (one of CommitChange's employees) have approved this org
    :verification_status, # str (either 'pending', 'unverified', 'escalated', 'verified' -- whether the org has submitted the identity verification form and it has been approved)
    :latitude, # float: geocoder gem
    :longitude, # float: geocoder gem
    :timezone, # str
    :address, # text
    :thank_you_note, # text
    :referrer, # str
    :no_anon, # bool: whether to allow anonymous donations
    :roles_attributes,
    :brand_font, # string (lowercase key eg. 'helvetica')
    :brand_color, # string (hex color value)
    :hide_activity_feed, # bool
    :tracking_script,
    :facebook, # string (url)
    :twitter, # string (url)
    :youtube, # string (url)
    :instagram, # string (url)
    :blog, # string (url)
    :card_failure_message_top, # text
    :card_failure_message_bottom, # text
    :autocomplete_supporter_address # boolean

  has_many :payouts
  has_many :charges
  has_many :refunds, through: :charges
  has_many :disputes, through: :charges
  has_many :donations
  has_many :recurring_donations
  has_many :payments do
    def pending
      joins(:charges).where("charges.status = ?", "pending")
    end

    def pending_totals
      net, gross = pending.pluck(Arel.sql('SUM("payments"."net_amount") AS net, SUM("payments"."gross_amount") AS gross')).first
      {"net" => net, "gross" => gross}
    end

    def during_np_year(year)
      proxy_association.owner.use_zone do
        where("payments.date >= ? and payments.date < ?", Time.zone.local(year), Time.zone.local(year + 1))
      end
    end

    def prior_to_np_year(year)
      proxy_association.owner.use_zone do
        where("date < ?", Time.zone.local(year))
      end
    end
  end

  has_many :supporters, dependent: :destroy do
    def dupes_on_email(strict_mode = true)
      QuerySupporters.dupes_on_email(proxy_association.owner.id, strict_mode)
    end

    def dupes_on_name(strict_mode = true)
      QuerySupporters.dupes_on_name(proxy_association.owner.id, strict_mode)
    end

    def dupes_on_name_and_email(strict_mode = true)
      QuerySupporters.dupes_on_name_and_email(proxy_association.owner.id, strict_mode)
    end

    def dupes_on_name_and_phone(strict_mode = true)
      QuerySupporters.dupes_on_name_and_phone(proxy_association.owner.id, strict_mode)
    end

    def dupes_on_name_and_phone_and_address(strict_mode = true)
      QuerySupporters.dupes_on_name_and_phone_and_address(proxy_association.owner.id, strict_mode)
    end

    def dupes_on_phone_and_email_and_address(strict_mode = true)
      QuerySupporters.dupes_on_phone_and_email_and_address(proxy_association.owner.id, strict_mode)
    end

    def dupes_on_name_and_address(strict_mode = true)
      QuerySupporters.dupes_on_name_and_address(proxy_association.owner.id, strict_mode)
    end

    def dupes_on_phone_and_email(strict_mode = true)
      QuerySupporters.dupes_on_phone_and_email(proxy_association.owner.id, strict_mode)
    end

    def dupes_on_address_without_zip_code(strict_mode = true)
      QuerySupporters.dupes_on_address_without_zip_code(proxy_association.owner.id, strict_mode)
    end

    def dupes_on_last_name_and_address
      QuerySupporters.dupes_on_last_name_and_address(proxy_association.owner.id)
    end

    def dupes_on_last_name_and_address_and_email
      QuerySupporters.dupes_on_last_name_and_address_and_email(proxy_association.owner.id)
    end

    def for_export_enumerable(query, chunk_limit = 15000)
      QuerySupporters.for_export_enumerable(proxy_association.owner.id, query, chunk_limit)
    end
  end
  has_many :transactions, through: :supporters
  has_many :supporter_notes, through: :supporters
  has_many :profiles, through: :donations
  has_many :campaigns, dependent: :destroy
  has_many :events, dependent: :destroy
  has_many :tickets, through: :events
  has_many :roles, as: :host, dependent: :destroy
  has_many :users, through: :roles
  has_many :tag_masters, dependent: :destroy
  has_many :custom_field_masters, dependent: :destroy
  has_many :activities, as: :host, dependent: :destroy
  has_many :imports
  has_many :email_settings
  has_many :cards, as: :holder
  has_many :supporter_cards, through: :supporters, source: :cards, class_name: "Card"
  has_many :periodic_reports
  has_many :export_formats

  has_one :nonprofit_key

  has_many :email_lists

  has_one :bank_account, -> { where("COALESCE(bank_accounts.deleted, false) = false") }, dependent: :destroy
  has_one :billing_subscription, dependent: :destroy
  has_one :billing_plan, through: :billing_subscription
  has_one :miscellaneous_np_info
  has_one :nonprofit_deactivation
  has_one :stripe_account, foreign_key: :stripe_account_id, primary_key: :stripe_account_id

  has_many :email_customizations

  has_many :associated_object_events, class_name: "ObjectEvent"

  validates :name, presence: true
  validates :city, presence: true
  validates :state_code, presence: true
  validates :email, format: {with: Email::Regex}, allow_blank: true
  validate :timezone_is_valid
  validates_uniqueness_of :slug, scope: [:city_slug, :state_code_slug]
  validates_presence_of :slug

  scope :vetted, -> { where(vetted: true) }
  scope :published, -> { where(published: true) }

  mount_uploader :main_image, NonprofitUploader
  mount_uploader :background_image, NonprofitBackgroundUploader
  mount_uploader :logo, NonprofitLogoUploader

  geocoded_by :full_address

  before_validation(on: :create) do
    set_slugs
    self
  end

  concerning :Path do
    class_methods do
      ModernParams = Struct.new(:to_param)
    end
    included do
      # When you use a routing helper like `api_new_nonprofit_supporter``, you need to provide objects which have a `#to_param`
      # method. By default that's set to the value of `#id`. In our case, for the api objects, we want the id to instead be
      # the value of `#houid`. We can't override `to_param` though because we may use route helpers which expect `#to_param` to
      # return the value of `#id`. This is the hacky workaround.
      def to_modern_param
        ModernParams.new(houid)
      end
    end
  end

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

  def url
    "/#{state_code_slug}/#{city_slug}/#{slug}"
  end

  def set_slugs
    unless slug
      self.slug = Format::Url.convert_to_slug name
    end
    unless city_slug
      self.city_slug = Format::Url.convert_to_slug city
    end

    unless state_code_slug
      self.state_code_slug = Format::Url.convert_to_slug state_code
    end
    self
  end

  def full_address
    Format::Address.full_address(address, city, state_code)
  end

  def total_raised
    QueryPayments.get_payout_totals(QueryPayments.ids_for_payout(id))["net_amount"]
  end

  def admins
    users.nonprofit_admins
  end

  def associates
    users.nonprofit_associates
  end

  def can_make_payouts?
    !!(vetted && bank_account &&
    !bank_account.deleted &&
    !bank_account.pending_verification &&
    stripe_account&.payouts_enabled &&
    !nonprofit_deactivation&.deactivated)
  end

  def can_process_charge?
    !!(vetted &&
      stripe_account&.charges_enabled &&
      !nonprofit_deactivation&.deactivated)
  end

  def active_cards
    cards.where("COALESCE(cards.inactive, FALSE) = FALSE")
  end

  # @param [Card] card the new active_card
  def active_card=(card)
    unless card.class == Card
      raise ArgumentError.new "Pass a card to active_card or else"
    end
    Card.transaction do
      active_cards.update_all inactive: true
      return cards << card
    end
  end

  def active_card
    active_cards.first
  end

  def create_active_card(card_data)
    if card_data[:inactive]
      raise ArgumentError.new "This method is for creating active cards only"
    end
    active_cards.update_all inactive: true
    cards.create(card_data)
  end

  def currency_symbol
    Settings.intntl.all_currencies.find { |i| i.abbv.downcase == currency.downcase }&.symbol
  end

  def steps_to_payout
    ret = []

    ret.push({name: :verification,
      status: stripe_account&.verification_status ||
        :unverified})
    no_bank_account = !bank_account || bank_account.deleted

    pending_bank_account = bank_account&.pending_verification

    bank_account && bank_account.pending_verification

    bank_status = if no_bank_account
      :no_bank_account
    elsif pending_bank_account
      :pending_bank_account
    else
      :valid_bank_account
    end

    ret.push({name: :bank_account, status: bank_status})

    ret.push({
      name: :vetted,
      status: vetted
    })
    ret
  end

  def autocomplete_supporter_address?
    !!(feature_flag_autocomplete_supporter_address && autocomplete_supporter_address)
  end

  concerning :FeeCalculation do
    # @param [Hash] opts
    # @option opts [#brand, #country] :source the source to use for calculating the fee
    # @option opts [Integer] :amount  the amount of the transaction in cents
    # @option opts [DateTime,nil] :at (nil) the time to use for searching for a FeeEra. Default of current time
    def calculate_fee(opts = {})
      FeeEra.calculate_fee(
        **opts,
        platform_fee: billing_plan.percentage_fee.to_s,
        flat_fee: billing_plan.flat_fee
      )
    end

    # @param [Hash] opts
    # @option opts [#brand, #country] :source  the source to use for calculating the fee
    # @option opts [Integer] :amount  the amount of the transaction in cents
    # @option opts [DateTime,nil] :at (nil) the time to use for searching for a FeeEra. Default of current time
    def calculate_stripe_fee(opts = {})
      FeeEra.calculate_stripe_fee(opts)
    end

    # @param [Hash] opts
    # @option opts [Time] :charge_date the date that the charge occurred for purposes of finding the correct fee era
    # @option opts [Stripe::Charge] :charge the Stripe::Charge to use for calculating the fee
    # @option opts [Stripe::Refund] :refund the Stripe::Refund for
    # @option opts [Stripe::ApplicationFee] :application_fee the Stripe::ApplicationFee for this Charge
    def calculate_application_fee_refund(opts = {})
      FeeEra.calculate_application_fee_refund(opts)
    end

    # the flat_fee and percentage_fee to use for calculating fee coverage on transactions for this nonprofit
    #
    # These fee_coverage details are calcuated as follows:
    #
    # {
    #   flat_fee: flat_fee as part of BillingPlan (unless FeeCoverageDetailsBase.dont_consider_billing_plan is true) + flat_fee from FeeCoverageDetailBase on current FeeEra,
    #   percentage_fee: percentage_fee as part of BillingPlan (unless FeeCoverageDetailsBase.dont_consider_billing_plan is true) + percentage_fee from FeeCoverageDetailBase on current FeeEra
    # }
    def fee_coverage_details
      return fee_coverage_details_no_billing_plan if !billing_plan
      {
        flat_fee: (FeeEra.current.fee_coverage_detail_base.dont_consider_billing_plan ? 0 : billing_plan.flat_fee) + FeeEra.current.fee_coverage_detail_base.flat_fee,
        percentage_fee: (FeeEra.current.fee_coverage_detail_base.dont_consider_billing_plan ? 0 : billing_plan.percentage_fee) + FeeEra.current.fee_coverage_detail_base.percentage_fee
      }
    end

    def fee_coverage_details_no_billing_plan
      {
        flat_fee: FeeEra.current.fee_coverage_detail_base.flat_fee,
        percentage_fee: FeeEra.current.fee_coverage_detail_base.percentage_fee
      }
    end

    def fee_coverage_details_with_json_safe_keys
      fee_coverage_details.transform_keys { |i| i.to_s.camelize(:lower) }
    end
  end

  concerning :Deactivation do
    included do
      define_model_callbacks :deactivate

      scope :activated, -> { includes(:nonprofit_deactivation).where("nonprofit_deactivations.nonprofit_id IS NULL OR NOT COALESCE(nonprofit_deactivations.deactivated, false)").references(:nonprofit_deactivations) }
      scope :deactivated, -> { joins(:nonprofit_deactivation).where("nonprofit_deactivations.deactivated = true") }
    end
    # Deactivate a nonprofit
    def deactivate!
      transaction do
        run_callbacks :deactivate do
          self.nonprofit_deactivation ||= NonprofitDeactivation.new
          self.nonprofit_deactivation.deactivated = true
          self.nonprofit_deactivation.save!
        end
      end
    end

    def deactivated?
      !!nonprofit_deactivation&.deactivated
    end

    def activated?
      !deactivated?
    end
  end

  concerning :Publishing do
    include Nonprofit::Deactivation
    included do
      before_deactivate :unpublish!
    end

    def unpublish!
      self.published = false
      save!
    end
  end

  concerning :S3Keys do
    included do
      has_many :nonprofit_s3_keys
    end
  end

  concerning :DateAndTime do
    # retrieve the ActiveSupport::TimeZone object for the Nonprofit
    # @return ActiveSupport::TimeZone the object representing the nonprofits set timezone; otherwise UTC
    def zone
      (timezone.present? && ActiveSupport::TimeZone[timezone]) || Time.zone
    end

    # use the Nonprofit's timezone in a block
    def use_zone(&block)
      Time.use_zone(zone) do
        yield block
      end
    end
  end

  def has_achievements?
    achievements.is_a?(Array) && achievements.any?
  end

  def hide_cover_fees?
    miscellaneous_np_info&.hide_cover_fees
  end

  def fee_coverage_option
    @fee_coverage_option ||= miscellaneous_np_info&.fee_coverage_option_config || "auto"
  end

  # generally, don't use
  attr_writer :fee_coverage_option

  concerning :PathCaching do
    included do
      after_save do
        clear_cache
        self
      end
    end
    class_methods do
      def clear_caching(id, state_code, city, name)
        Rails.cache.delete(Nonprofit.create_cache_key_for_id(id))
        Rails.cache.delete(Nonprofit.create_cache_key_for_location(state_code, city, name))
        BillingSubscription.clear_cache(id)
        BillingPlan.clear_cache(id)
      end

      def find_via_cached_id(id)
        key = create_cache_key_for_id(id)
        Rails.cache.fetch(key, expires_in: 4.hours) do
          Nonprofit.find(id)
        end
      end

      def find_via_cached_key_for_location(state_code, city, name)
        key = create_cache_key_for_location(state_code, city, name)
        Rails.cache.fetch(key, expires_in: 4.hours) do
          Nonprofit.where(state_code_slug: state_code, city_slug: city, slug: name).last
        end
      end

      def create_cache_key_for_id(id)
        "nonprofit__CACHE_KEY__ID___#{id}"
      end

      def create_cache_key_for_location(state_code, city, name)
        "nonprofit__CACHE_KEY__LOCATION___#{state_code}____#{city}___#{name}"
      end
    end

    def clear_cache
      Nonprofit.clear_caching(id, state_code_slug, city_slug, slug)
    end
  end

  concerning :TaxReceipting do
    def supporters_who_have_payments_during_year(year, tickets: false)
      payments_during_year = payments.during_np_year(year)
      unless tickets
        payments_during_year = payments_during_year.where("kind IS NULL OR kind != ? ", "ticket")
      end
      payments_during_year.group("supporter_id").select("supporter_id, COUNT(id)").each.map(&:supporter)
    end

    def supporters_who_have_payments_prior_to_year(year, tickets: false)
      payments_during_year = payments.during_np_year(year)
      payments_during_year.group("supporter_id").select("supporter_id, COUNT(id)").each.map(&:supporter)
    end
  end

  private

  def timezone_is_valid
    timezone.blank? || ActiveSupport::TimeZone.all.map { |t| t.tzinfo.name }.include?(timezone) || errors.add(:timezone, "is not a valid timezone")
  end
end
