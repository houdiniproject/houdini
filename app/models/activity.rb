# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class Activity < ApplicationRecord
  belongs_to :attachment, polymorphic: true
  belongs_to :supporter
  belongs_to :nonprofit
  belongs_to :user

  def json_data=(data)
    write_attribute :json_data, JSON.generate(data)
  end

  def json_data
    JSON.parse(read_attribute(:json_data))
  end
end
