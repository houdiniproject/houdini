# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class SupporterEmail < ApplicationRecord
	# TODO
	# attr_accessible \
	# 	:to,
	# 	:from,
	# 	:subject,
	# 	:body,
	# 	:recipient_count,
	# 	:supporter_id, :supporter,
	# 	:nonprofit_id,
	# 	:gmail_thread_id

	belongs_to :supporter
	validates_presence_of :nonprofit_id
	has_many :activities, as: :attachment, dependent: :destroy
end
