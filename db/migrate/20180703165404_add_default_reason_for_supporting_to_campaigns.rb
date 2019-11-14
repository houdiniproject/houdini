# frozen_string_literal: true

class AddDefaultReasonForSupportingToCampaigns < ActiveRecord::Migration[4.2]
  def change
    add_column :campaigns, :default_reason_for_supporting, :text
  end
end
