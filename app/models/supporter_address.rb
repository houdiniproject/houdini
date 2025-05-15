# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class SupporterAddress < ApplicationRecord
  belongs_to :supporter, optional: false, inverse_of: :addresses

  def primary?
    supporter&.primary_address == self
  end
end
