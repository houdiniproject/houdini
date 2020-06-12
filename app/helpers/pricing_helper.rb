# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
module PricingHelper
  private

  def nonprofit_email
    return nil if @nonprofit.nil?

    @nonprofit.email || GetData.chain(@nonprofit.users.first, :email)
  end
end
