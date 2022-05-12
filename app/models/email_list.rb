# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class EmailList < ActiveRecord::Base
  belongs_to :nonprofit
  belongs_to :tag_master
end
