# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later

# InterpolationDictionary is a simple class for replacing braced variables,
# like {{NAME}}, with a different value. We use this for email templates.
class SupporterInterpolationDictionary < InterpolationDictionary
  def set_supporter(supporter)
    if supporter.is_a?(Supporter) && supporter&.name&.present?
      add_entry('NAME', supporter&.name&.strip)
      if supporter.name&.strip.split(' ')[0].present?
        add_entry('FIRSTNAME', supporter.name&.strip.split(' ')[0])
      end
    end
  end
end