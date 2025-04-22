class Reassignment < ApplicationRecord
  belongs_to :item, polymorphic: true
  belongs_to :e_tap_import
  belongs_to :source_supporter, class_name: "Supporter", foreign_key: "source_supporter_id"
  belongs_to :target_supporter, class_name: "Supporter", foreign_key: "target_supporter_id"
end
