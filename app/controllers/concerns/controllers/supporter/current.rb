# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
module Controllers::Supporter::Current
  include Controllers::Nonprofit::Current
  extend ActiveSupport::Concern
  included do
    private

    def current_supporter
      current_nonprofit.supporters.find(params[:supporter_id] || params[:id])
    end
  end
end
