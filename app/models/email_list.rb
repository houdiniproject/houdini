# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class EmailList < ApplicationRecord
  attr_accessible :list_name, :mailchimp_list_id, :nonprofit, :tag_master
  belongs_to :nonprofit
  belongs_to :tag_master
end
