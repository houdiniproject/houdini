# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
module Controllers::XFrame
  extend ActiveSupport::Concern

  included do
    private

    # allows the page to be put in a frame, i.e. remove the X-Frame-Options header
    def allow_framing
      response.headers.delete("X-Frame-Options") if response.headers.has_key?("X-Frame-Options")
    end
  end
end
