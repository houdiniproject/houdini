# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class CreateEmailCustomizations < ActiveRecord::Migration
  def change
    create_table :email_customizations do |t|
      t.string :name, index: true
      t.text :contents
      t.references :nonprofit, foreign_key: true, null: false, index: true

      t.timestamps null: false
    end
  end
end
