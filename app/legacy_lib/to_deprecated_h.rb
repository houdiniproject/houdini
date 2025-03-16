# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class Hash
  # a common method to always get a hash regardless of whether using an ActionController::Parameters or a hash
  def to_deprecated_h
    to_h
  end
end

module ActionController
  class Parameters
    # a common method to always get a hash regardless of whether using an ActionController::Parameters or a hash
    def to_deprecated_h
      to_unsafe_h
    end
  end
end