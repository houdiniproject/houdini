class Export < ActiveRecord::Base

  STATUS = %w[queued started completed failed].freeze
  attr_accessible :exception, :nonprofit, :status, :user, :export_type, :parameters, :ended, :url, :user_id, :nonprofit_id

  belongs_to :nonprofit
  belongs_to :user

  validates :user, presence: true
end
