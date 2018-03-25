class DateTime
  def nsec
    (sec_fraction * 1_000_000_000).to_i
  end
end