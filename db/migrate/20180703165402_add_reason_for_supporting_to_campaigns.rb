# frozen_string_literal: true

class AddReasonForSupportingToCampaigns < ActiveRecord::Migration
  def change
    add_column :campaigns, :reason_for_supporting, :text
  end
end
