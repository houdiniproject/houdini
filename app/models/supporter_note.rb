class SupporterNote < ActiveRecord::Base

	attr_accessible \
		:content,
		:supporter_id, :supporter

	belongs_to :supporter
	has_many :activities, as: :attachment, dependent: :destroy

	validates :content, length: {minimum: 1}
	validates :supporter_id, presence: true
end

