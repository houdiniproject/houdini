# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class Houdini::FullContact::FullContactListener
  def name
    self.class.name
  end

  def self.supporter_create(supporter)
    FullContactJob.perform_later(supporter)
  end
end
