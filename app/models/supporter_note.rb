# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class SupporterNote < ApplicationRecord

	#TODO
	# attr_accessible \
	# 	:content,
	# 	:supporter_id, :supporter

	belongs_to :supporter
	has_many :activities, as: :attachment, dependent: :destroy

	validates :content, length: {minimum: 1}
	validates :supporter_id, presence: true
end

