# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
# Hamster extesions/modifications

# Default Hamster to_json methods don't work right
module ProperJson
  def to_json(options = {})
    Hamster.to_ruby(self).to_json(options)
  end
end

Hamster::Vector.send(:include, ProperJson)
Hamster::Hash.send(:include, ProperJson)
