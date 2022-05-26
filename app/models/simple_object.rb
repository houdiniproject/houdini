# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
#
# ONLY USED FOR TESTING
# This file is basically a super simple mock for testing certain behaviors around events and relationship
# We use it in specs only
class SimpleObject < ActiveRecord::Base
  include Model::Houidable
  setup_houid :smplobj, :houid
  belongs_to :parent, class_name: "SimpleObject"
  belongs_to :nonprofit

  has_many :friends, class_name: "SimpleObject", foreign_key: 'friend_id'

end
