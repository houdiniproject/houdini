# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
# Immutable extesions/modifications
require 'immutable'
# Default Immutable to_json methods don't work right
module ProperJson
  def to_json(options={})
    Immutable.to_ruby(self).to_json(options)
  end
end

Immutable::Vector.send(:include, ProperJson)
Immutable::Hash.send(:include, ProperJson)
