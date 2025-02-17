# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
module Model::CreatedTimeable
  extend ActiveSupport::Concern
  included do
    after_initialize :set_created_if_needed

    private

    def set_created_if_needed
      self[:created] = Time.current unless self[:created]
    end
  end
end
