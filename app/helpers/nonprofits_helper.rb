# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
module NonprofitsHelper
  def managed_npo_card_json
    if current_user
      if params[:nonprofit_id] && current_role?(:super_admin)
        raw(Nonprofit.find(params[:nonprofit_id]).active_card.to_json)
      elsif administered_nonprofit&.active_card
        raw(administered_nonprofit.active_card.to_json)
      end
    else
      'undefined'
    end
  end
end
