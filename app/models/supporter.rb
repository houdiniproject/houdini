# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class Supporter < ActiveRecord::Base

  include Model::Houidable
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
  has_many :payments
  has_many :offsite_payments

  has_many :charges
  has_many :refunds, through: :charges
  has_many :disputes, through: :charges

  has_many :cards, as: :holder
  has_many :direct_debit_details
  has_many :donations
  has_many :supporter_notes, dependent: :destroy
  has_many :supporter_emails
  has_many :activities, dependent: :destroy
  has_many :tickets
  has_many :recurring_donations
  has_many :tag_joins, dependent: :destroy
  has_many :tag_masters, through: :tag_joins
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

  def calculated_first_name
    name_parts = name&.strip&.split(' ')&.map(&:strip)
    case name_parts&.count || 0
    when 0
      nil
    when 1
      name_parts[0]
    else
      name_parts[0..-2].join(" ")
    end
  end

  def calculated_last_name
    name_parts = name&.strip&.split(' ')&.map(&:strip)
    case name_parts&.count || 0
    when 0
      nil
    when 1
      nil
    else
      name_parts[-1]
    end
  end

  def profile_picture size=:normal
    return unless self.profile
    self.profile.get_profile_picture(size)
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
end
