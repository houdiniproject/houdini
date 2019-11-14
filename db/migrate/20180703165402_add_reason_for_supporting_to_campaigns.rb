# frozen_string_literal: true

class AddReasonForSupportingToCampaigns < ActiveRecord::Migration[4.2]
  def change
    add_column :campaigns, :reason_for_supporting, :text
  end
end
