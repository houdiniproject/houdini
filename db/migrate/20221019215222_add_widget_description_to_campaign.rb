# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class AddWidgetDescriptionToCampaign < ActiveRecord::Migration
  def change
    add_reference :campaigns, :widget_description, index: true
  end
end
