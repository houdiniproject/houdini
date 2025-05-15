# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class EmailSetting < ApplicationRecord
  belongs_to :nonprofit
  belongs_to :user
end
