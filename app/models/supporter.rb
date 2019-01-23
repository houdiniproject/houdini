# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class Supporter < ActiveRecord::Base

  attr_accessible \
    :search_vectors,
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
    :is_unsubscribed_from_emails #bool

  belongs_to :profile
  belongs_to :nonprofit
  belongs_to :import
  has_many :full_contact_infos
  has_many :payments
  has_many :offsite_payments
  has_many :charges
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

  validates :nonprofit, :presence => true
  scope :not_deleted, -> {where(deleted: false)}

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

end
