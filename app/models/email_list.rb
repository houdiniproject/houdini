class EmailList < ActiveRecord::Base
  attr_accessible :list_name, :mailchimp_list_id
  belongs_to :nonprofit
  belongs_to :tag_master
end
