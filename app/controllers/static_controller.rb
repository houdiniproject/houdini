# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class StaticController < ApplicationController
  layout "layouts/static"

  def terms_and_privacy
    @theme = "minimal"
  end

  def ccs
    Houdini.ccs.retrieve_ccs do |ccs|
      if ccs.is_a? String
        redirect_to ccs
      else
        send_data(ccs, type: "application/gzip")
      end
    end
  rescue
    render body: nil, status: 500
  end
end
