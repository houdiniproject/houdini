# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
module UpdateCampaignGiftOption
  def self.update(gift_option, params)
    gift_option.update params
    gift_option
  end
end
