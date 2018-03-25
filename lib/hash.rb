class Hash
  def keep_keys(*keys)
    keys = keys.map{|k| k.to_s}
    clone.delete_if{|k,v| !keys.include?(k.to_s)}
  end

  def keep_keys!(*keys)
    keys = keys.map{|k| k.to_s}
    delete_if{|k,v| !keys.include?(k.to_s)}
  end
end
