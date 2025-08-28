class AddVirtualToEvent < ActiveRecord::Migration[7.1]
  def change
    add_column :events, :in_person_or_virtual, :string, default: "in_person", comment: "whether or not this is a virtual event"

    add_index :events, :in_person_or_virtual
  end
end
