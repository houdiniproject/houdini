# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class Activity < ApplicationRecord
  belongs_to :attachment, polymorphic: true
  belongs_to :supporter
  belongs_to :nonprofit
end
