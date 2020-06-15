# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
class Comment < ApplicationRecord
  # :host_id,
  # :host_type, # parent: Event, Campaign, nil
  # :profile_id,
  # :body

  validates :profile, presence: true
  validates :body, presence: true, length: { maximum: 200 }

  has_one :activity, as: :attachment, dependent: :destroy
  belongs_to :host, polymorphic: true
  belongs_to :donation
  belongs_to :profile

  before_validation(on: :create) do
    remove_newlines
  end

  after_create do
    create_activity(
      desc: 'commented',
      profile_id: profile_id,
      host_id: host_id,
      host_type: host_type,
      body: body
    )
  end

  def remove_newlines
    self.body = body && body.delete("\n")
  end
end
