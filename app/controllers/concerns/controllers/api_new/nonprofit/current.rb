# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE

# You need this is in (ApiController)s. Eventually it should be used for all controllers but we're not there yet.
module Controllers::ApiNew::Nonprofit::Current
  extend ActiveSupport::Concern
  included do
    private

    def current_nonprofit
      result = Nonprofit.find_by(houid: params[:nonprofit_id])
      if Rails.version < "5" && result.nil?
        raise ActiveRecord::RecordNotFound.new
      end

      result
    end

    def current_nonprofit_without_exception
      current_nonprofit
    rescue
      false
    end
  end
end
