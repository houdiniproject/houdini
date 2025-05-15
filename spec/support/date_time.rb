# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class DateTime
  def nsec
    (sec_fraction * 1_000_000_000).to_i
  end
end
