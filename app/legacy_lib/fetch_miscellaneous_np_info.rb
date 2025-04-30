# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module FetchMiscellaneousNpInfo
  def self.fetch(np_id)
    ParamValidation.new({np_id: np_id}, np_id: {required: true, is_integer: true})
    raise ParamValidation::ValidationError.new("Nonprofit #{np_id} does not exist", {key: :np_id}) unless Nonprofit.exists?(np_id)
    MiscellaneousNpInfo.where("nonprofit_id = ?", np_id).first_or_initialize
  end
end
