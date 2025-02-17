# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
module FetchMiscellaneousNpInfo
  def self.fetch(np_id)
    ParamValidation.new({np_id: np_id}, np_id: {required: true, is_integer: true})
    raise ParamValidation::ValidationError.new("Nonprofit #{np_id} does not exist", key: :np_id) unless Nonprofit.exists?(np_id)

    MiscellaneousNpInfo.where("nonprofit_id = ?", np_id).first_or_initialize
  end
end
