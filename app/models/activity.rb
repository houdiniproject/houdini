# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class Activity < ActiveRecord::Base
  belongs_to :attachment, :polymorphic => true
  belongs_to :supporter
  belongs_to :nonprofit

  attr_accessible \
    :supporter,
    :nonprofit,
    :date,
    :kind,
    :json_data,
    :attachment_type
  
  # def json_data=(data)
  #   write_attribute :json_data, data
  # end

  # def json_data
  #   JSON::parse(read_attribute :json_data)
  # end
end

