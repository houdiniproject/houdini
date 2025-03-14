# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
module Controllers::Nonprofit::Current
  extend ActiveSupport::Concern
  included do
    private

    def current_nonprofit
      @nonprofit = current_nonprofit_without_exception
      raise ActionController::RoutingError, "Nonprofit not found" if @nonprofit.nil?

      @nonprofit
    end

    def current_nonprofit_without_exception
      FetchNonprofit.with_params params, administered_nonprofit
    end
  end
end
