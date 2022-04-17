# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class Supporter < ApplicationRecord
  include Model::Jbuilder
  # :search_vectors,
  # :profile_id, :profile,
  # :nonprofit_id, :nonprofit,
  # :full_contact_info, :full_contact_info_id,
  # :import_id, :import,
  # :name,
  # :first_name,
  # :last_name,
  # :email,
  # :address,
  # :city,
  # :state_code,
  # :country,
  # :phone,
  # :organization,
  # :locale,
  # :zip_code,
  # :total_raised,
  # :notes,
  # :fields,
  # :anonymous,
  # :deleted, # bool (flag for soft delete)
  # :email_unsubscribe_uuid, #string
  # :is_unsubscribed_from_emails #bool

  belongs_to :profile
  belongs_to :nonprofit
  belongs_to :import
  
  has_many :payments
  has_many :offsite_payments
  has_many :charges
  has_many :cards, as: :holder
  has_many :direct_debit_details
  has_many :donations
  has_many :supporter_notes, dependent: :destroy
  has_many :activities, dependent: :destroy
  has_many :tickets
  has_many :recurring_donations
  has_many :tag_joins, dependent: :destroy
  has_many :tag_definitions, through: :tag_joins
  has_many :custom_field_joins, dependent: :destroy
  has_many :custom_field_definitions, through: :custom_field_joins
  has_many :transactions
  belongs_to :merged_into, class_name: 'Supporter', foreign_key: 'merged_into'
  has_many :merged_from, class_name: 'Supporter', :foreign_key => "merged_into"

  validates :nonprofit, presence: true
  scope :not_deleted, -> { where(deleted: false) }



  # TODO replace with Discard gem
  define_model_callbacks :discard

  after_discard :publish_deleted

  after_create_commit :publish_create
  after_update_commit :publish_updated

  # TODO replace with discard gem
  def discard!
    run_callbacks(:discard) do
      self.deleted = true
      save!
    end
  end

  def profile_picture(size = :normal)
    return unless profile

    profile.get_profile_picture(size)
  end

  def as_json(options = {})
    h = super(**options)
    h[:pic_tiny] = profile_picture(:tiny)
    h[:pic_normal] = profile_picture(:normal)
    h[:url] = profile && Rails.application.routes.url_helpers.profile_path(profile)
    h
  end

  concerning :Jbuilder do 
    included do 
      def to_builder(*expand)
        supporter_addresses = [self]
        init_builder(*expand) do |json|
          json.(self, :name, :organization, :phone, :anonymous, :deleted)
          json.add_builder_expansion :nonprofit, :merged_into
          if expand.include? :supporter_address
            json.supporter_addresses supporter_addresses do |i|
              json.merge! i.to_supporter_address_builder.attributes!
            end
          else
            json.supporter_addresses [id]
          end
        end
      end

      def to_supporter_address_builder(*expand)
        init_builder(*expand) do |json|
          json.(self, :address, :state_code, :city, :country, :zip_code, :deleted)
          json.object 'supporter_address'
          if expand.include? :supporter
            json.supporter to_builder
          else
            json.supporter id
          end
          json.add_builder_expansion :nonprofit
        end
      end
    end
  end

  

  def full_address
    Format::Address.full_address(address, city, state_code)
  end

  private

  ADDRESS_ATTRIBUTES = [:address, :city, :state_code, :zip_code, :country]

  def supporter_address_updated?
    ADDRESS_ATTRIBUTES.any?{|attrib| saved_change_to_attribute?(attrib)}
  end

  def nonsupporter_address_updated?
    (saved_changes.keys.map(&:to_sym) - ADDRESS_ATTRIBUTES).any?
  end

  def publish_create
    Houdini.event_publisher.announce(:supporter_created, to_event('supporter.created', :supporter_address, :nonprofit).attributes!)
    Houdini.event_publisher.announce(:supporter_address_created, to_event('supporter_address.created', :supporter, :nonprofit).attributes!)
  end

  def publish_updated
    if !deleted
      if nonsupporter_address_updated?
        Houdini.event_publisher.announce(:supporter_updated, to_event('supporter.updated', :supporter_address, :nonprofit).attributes!)
      end
      if supporter_address_updated?
        Houdini.event_publisher.announce(:supporter_address_updated, to_event('supporter_address.updated', :supporter, :nonprofit).attributes!)
      end
    end
  end

  def publish_deleted
    Houdini.event_publisher.announce(:supporter_deleted, to_event('supporter.deleted', :supporter_address, :nonprofit, :merged_into).attributes!)
    Houdini.event_publisher.announce(:supporter_address_deleted, to_event('supporter_address.deleted', :supporter, :nonprofit).attributes!)
  end

  # we do something custom here since Supporter and SupporterAddress are in the same model
  def to_event(event_type, *expand)
    ::Jbuilder.new do |event|
        event.id "objevt_" + SecureRandom.alphanumeric(22)
        event.object 'object_event'
        event.type event_type
        event.data do 
          event.object event_type.start_with?('supporter_address') ? to_supporter_address_builder(*expand) : to_builder(*expand)
        end
    end
  end
end

ActiveSupport.run_load_hooks(:houdini_supporter, Supporter)