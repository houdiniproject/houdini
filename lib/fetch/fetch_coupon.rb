# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module FetchCoupon
  def self.page(params)
    return params[:name].tr('-', '_') if params[:name]
  end
end
