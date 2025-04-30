# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
module Model::CalculatedNames
  extend ActiveSupport::Concern
  included do
    def calculated_first_name
      name_parts = name&.strip&.split(" ")&.map(&:strip)
      case name_parts&.count || 0
      when 0
        nil
      when 1
        name_parts[0]
      else
        name_parts[0..-2].join(" ")
      end
    end

    def calculated_last_name
      name_parts = name&.strip&.split(" ")&.map(&:strip)
      case name_parts&.count || 0
      when 0
        nil
      when 1
        nil
      else
        name_parts[-1]
      end
    end
  end
end
