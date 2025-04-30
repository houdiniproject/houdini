class Reassignment < ApplicationRecord
  belongs_to :item, polymorphic: true
  belongs_to :e_tap_import
  belongs_to :source_supporter, class_name: "Supporter"
  belongs_to :target_supporter, class_name: "Supporter"
end
