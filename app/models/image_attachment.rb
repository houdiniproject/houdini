# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class ImageAttachment < ApplicationRecord
  include Image::AttachmentExtensions
  # :parent_id,
  # :file
  has_one_attached :file

  has_one_attached_with_sizes :file, {large: [600, 400], medium: [400, 266], small: [400, 266], thumb_explore: [200, 133]}

  # not sure if poly parent is used on this model, as all values are nil in db
  belongs_to :parent, polymorphic: true
end
