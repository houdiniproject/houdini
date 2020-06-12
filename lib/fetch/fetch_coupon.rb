# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
module FetchCoupon
  def self.page(params)
    return params[:name].tr('-', '_') if params[:name]
  end
end
