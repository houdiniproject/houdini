# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
module ListActivities
  def self.with_params(params, default_activities = nil)
    acts = default_activities || Activity
    acts = acts.includes(:supporter, :attachment, :host).order('created_at DESC')
    acts = acts.where(host_id: params[:host_id]) unless params[:host_id].blank?
    acts = acts.where(attachment_id: params[:attachment_id]) unless params[:attachment_id].blank?
    acts = acts.where(nonprofit_id: params[:nonprofit_id]) unless params[:nonprofit_id].blank?
    acts = acts.is_public if params[:public]
    acts = acts.limit(params[:limit]) unless params[:limit].blank?
    acts
  end
end
