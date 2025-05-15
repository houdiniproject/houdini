# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module UpdateMiscellaneousNpInfo
  def self.update(np_id, misc_settings)
    ParamValidation.new({np_id: np_id, misc_settings: misc_settings},
      np_id: {required: true, is_integer: true},
      misc_settings: {required: true, is_hash: true})
    np = Nonprofit.where("id = ?", np_id).first
    raise ParamValidation::ValidationError.new("Nonprofit #{np_id} does not exist", {key: :np_id}) unless np
    misc = MiscellaneousNpInfo.where("nonprofit_id = ?", np_id).first
    unless misc
      misc = MiscellaneousNpInfo.new
      misc.nonprofit = np
    end
    if misc_settings[:donate_again_url].present?
      misc.donate_again_url = misc_settings[:donate_again_url]
    end

    if misc_settings[:change_amount_message].present?
      misc.change_amount_message = if Format::HTML.has_only_empty_tags(misc_settings[:change_amount_message])
        nil
      else
        misc_settings[:change_amount_message]
      end
    end

    misc.save!
    misc
  end
end
