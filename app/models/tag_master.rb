class TagMaster < ActiveRecord::Base

	attr_accessible \
		:nonprofit, :nonprofit_id,
		:name,
		:deleted,
		:created_at

	validates :name, presence: true
	validate :no_dupes, on: :create

	belongs_to :nonprofit
	has_many :tag_joins, dependent: :destroy

	scope :not_deleted, ->{where(deleted: [nil,false])}

	def no_dupes
		return self if nonprofit.nil?
		errors.add(:base, "Duplicate tag") if nonprofit.tag_masters.not_deleted.where(name: name).any?
	end

end

