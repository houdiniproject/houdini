# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
# Hamster extesions/modifications

# Default Hamster to_json methods don't work right
module ProperJson
  def to_json(options={})
    Hamster.to_ruby(self).to_json(options)
  end
end

Hamster::Vector.send(:include, ProperJson)
Hamster::Hash.send(:include, ProperJson)
