class CreateWidgetDescriptions < ActiveRecord::Migration
  def change
    create_table :widget_descriptions do |t|
      t.string :houid, null: false, index: {unique: true}
      t.string :custom_recurring_donation_phrase
      t.jsonb :custom_amounts
      t.jsonb :postfix_element

      t.timestamps null: false
    end
  end
end
