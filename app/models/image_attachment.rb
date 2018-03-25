class ImageAttachment < ActiveRecord::Base

	attr_accessible :parent_id, :file
	mount_uploader :file, ImageAttachmentUploader

	# not sure if poly parent is used on this model, as all values are nil in db
	belongs_to :parent, :polymorphic => true

end
