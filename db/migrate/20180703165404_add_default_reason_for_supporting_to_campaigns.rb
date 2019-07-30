# frozen_string_literal: true

class AddDefaultReasonForSupportingToCampaigns < ActiveRecord::Migration
  def change
    add_column :campaigns, :default_reason_for_supporting, :text
  end
end
