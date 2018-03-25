# Hamster extesions/modifications

# Default Hamster to_json methods don't work right
module ProperJson
  def to_json(options={})
    Hamster.to_ruby(self).to_json(options)
  end
end

Hamster::Vector.send(:include, ProperJson)
Hamster::Hash.send(:include, ProperJson)
