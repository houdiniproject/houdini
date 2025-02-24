# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class Supporter < ApplicationRecord
  include Model::Houidable
  include Model::CalculatedNames
  setup_houid :supp, :houid

  ADDRESS_FIELDS = ['address', 'city', 'state_code', 'country', 'zip_code']

  before_validation :cleanup_address
  before_validation :cleanup_name

  before_save :update_primary_address

  attr_accessor :address_line2
  
  attr_accessible \
    :profile_id, :profile,
    :nonprofit_id, :nonprofit,
    :full_contact_info, :full_contact_info_id,
    :import_id, :import,
    :name,
    :first_name,
    :last_name,
    :email,
    :address,
    :city,
    :state_code,
    :country,
    :phone,
    :organization,
    :latitude,
    :locale,
    :longitude,
    :zip_code,
    :total_raised,
    :notes,
    :fields,
    :anonymous,
    :deleted, # bool (flag for soft delete)
    :email_unsubscribe_uuid, #string
    :is_unsubscribed_from_emails, #bool
    :id,
    :created_at,
    :address_line2,
    :primary_address

  # fts is generated via a trigger
	attr_readonly :fts

  belongs_to :profile
  belongs_to :nonprofit
  belongs_to :import
  has_many :full_contact_infos
  has_many :payments do
    def during_np_year(year)
      proxy_association.owner.nonprofit.use_zone do
        where('payments.date >= ? and payments.date < ?', Time.zone.local(year), Time.zone.local(year + 1))
      end
    end

    def donation_payments
      where('kind IN (?)', ['Donation', 'RecurringDonation'])
    end

    def refund_payments
      where('kind IN (?)', ['Refund'])
    end

    def dispute_payments
      where('kind IN (?)', ['Dispute'])
    end

    def dispute_reversal_payments
      where('kind IN (?)', ['DisputeReversed'])
    end
  end
  has_many :offsite_payments

  has_many :charges
  has_many :refunds, through: :charges
  has_many :disputes, through: :charges
  has_many :transactions

  has_many :cards, as: :holder
  has_many :direct_debit_details
  has_many :donations
  has_many :supporter_notes, dependent: :destroy
  has_many :supporter_emails
  has_many :activities, dependent: :destroy
  has_many :tickets
  has_many :recurring_donations
  has_many :object_events, as: :event_entity

  concerning :Tags do
    included do
      has_many :tag_joins, dependent: :destroy
      has_many :tag_masters, through: :tag_joins
      has_many :undeleted_tag_masters, -> { not_deleted }, through: :tag_joins, source: 'tag_master'
    end
  end

  concerning :EmailLists do
    include Supporter::Tags # not needed but helpful for tracking dependencies
    included do
      has_many :email_lists, through: :tag_masters
      has_many :active_email_lists, through: :undeleted_tag_masters, source: :email_list do
        def update_member_on_all_lists
          proxy_association.reload.target.each do |list| # We're reloading the association and running .each on target
            #to make sure we get any newly saved email lists. I think this should be simpler but I'm not sure how to do it.
            MailchimpSignupJob.perform_later(proxy_association.owner, list)
          end
        end
      end

      after_save :try_update_member_on_all_lists
    end

    def must_update_email_lists?
      saved_change_to_attribute?("name") || saved_change_to_attribute?("email")
    end

    def publish_created
      object_events.create(event_type: 'supporter.created')
    end

    private
    
    def try_update_member_on_all_lists
      update_member_on_all_lists if must_update_email_lists?
    end 

    def update_member_on_all_lists
      active_email_lists.update_member_on_all_lists
    end

  end
  
  has_many :custom_field_joins, dependent: :destroy
  has_many :custom_field_masters, through: :custom_field_joins
  belongs_to :merged_into, class_name: 'Supporter', :foreign_key => 'merged_into'
  has_many :merged_from, class_name: 'Supporter', :foreign_key => "merged_into"

  has_many :addresses, class_name: "SupporterAddress", after_add: :set_address_to_primary_if_needed
  belongs_to :primary_address, class_name: "SupporterAddress"

  validates :nonprofit, :presence => true
  scope :not_deleted, -> {where(deleted: false)}
  scope :deleted, -> {where(deleted: true)}
  scope :merged, -> {where('merged_at IS NOT NULL')}
  scope :not_merged, -> {where('merged_at IS NULL')}

  geocoded_by :full_address
  reverse_geocoded_by :latitude, :longitude do |obj, results|
    geo = results.first
    if geo # absorb zip code automatically
      obj.zip_code = geo.postal_code if obj.zip_code.blank?
      obj.state_code = geo.state_code if obj.state_code.blank?
      obj.city = geo.city if obj.city.blank?
      obj.address = geo.address if obj.address.blank?
      obj.country = geo.country if obj.country.blank?
    end
  end

  def profile_picture size=:normal
    return unless self.profile
    self.profile.get_profile_picture(size)
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



  # Supporters can be merged many times. This finds the last
  # supporter after following merged_into until it gets a nil
  def end_of_merge_chain
    if merged_into.nil?
      return self
    else
      merged_into.end_of_merge_chain
    end
  end


  def as_json(options = {})
    h = super(options)
    h[:pic_tiny] = self.profile_picture(:tiny)
    h[:pic_normal] = self.profile_picture(:normal)
    h[:url] = self.profile && Rails.application.routes.url_helpers.profile_path(self.profile)
    return h
  end

  def full_address
    Format::Address.full_address(self.address, self.city, self.state_code)
  end

  private
  def cleanup_address
    if address.present? && address_line2.present?
      assign_attributes(address_line2: nil, address: self.address + " " + self.address_line2)
    end
    address_field_attributes.each do |addr_attribute, addr_value|
      self[addr_attribute] = nil if addr_value.blank?
    end
  end

  def cleanup_name 
    if first_name.present? || last_name.present?
      assign_attributes(name: [first_name&.strip, last_name&.strip].select{|i| i.present?}.join(" "))
      assign_attributes(first_name: nil, last_name: nil)
    end
  end

  def address_field_attributes
    attributes.slice(*ADDRESS_FIELDS)
  end

  def filled_address_fields?
    address_field_attributes.any? { |column, value| value.present? }
  end

  def update_primary_address
    if self.changes.slice(*ADDRESS_FIELDS).any? #changed an address field
      if filled_address_fields?
        if primary_address.nil?
          self.addresses.build(address_field_attributes)
        else
          primary_address.update(address_field_attributes)
        end
      elsif primary_address.present?
        prim_addr = primary_address
        self.update(primary_address: nil)
        self.addresses.delete(prim_addr)
        prim_addr.destroy
      end
    end
  end

  def set_address_to_primary_if_needed(new_address)
    if primary_address.nil?
      assign_attributes(primary_address: new_address)
    end
  end

  concerning :Mailchimp do
    def md5_hash_of_email
      Digest::MD5.hexdigest email.downcase
    end
  end
end
