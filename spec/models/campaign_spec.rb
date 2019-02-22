# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'

RSpec.describe Campaign, type: :model do
  describe 'goal_amount' do
    before(:each) do
      @nonprofit = create(:nonprofit)

    end

    it 'when goal_is_in_supporters = true validate starting point and goal_amount' do

      campaign = Campaign.new(:starting_point => 'ethwohgniu', goal_is_in_supporters: true)

      campaign.valid?

      expect(campaign.errors[:starting_point].any? {|i| i.include?("not a number")}).to be_truthy

      ["can't be blank", "not a number", "greater than or equal to 1"].each do |expected|
        expect(campaign.errors[:goal_amount].any? {|i| i.include?(expected)}).to be_truthy
      end

      campaign = Campaign.new(:starting_point => '1.3', goal_is_in_supporters: true, goal_amount: 4.5)

      campaign.valid?

      expect(campaign.errors[:starting_point].any? {|i| i.include?("be an integer")}).to be_truthy

      expect(campaign.errors[:goal_amount].any? {|i| i.include?("be an integer")}).to be_truthy
    end

    it 'when goal_is_in_supporters = false validate starting point and goal_amount' do

      campaign = Campaign.new(:starting_point => 'ethwohgniu', goal_is_in_supporters: false)

      campaign.valid?

      expect(campaign.errors[:starting_point].any? {|i| i.include?("not a number")}).to be_truthy

      ["can't be blank", "not a number", "greater than or equal to 99"].each do |expected|
        expect(campaign.errors[:goal_amount].any? {|i| i.include?(expected)}).to be_truthy
      end

      campaign = Campaign.new(:starting_point => '1.3', goal_is_in_supporters: true, goal_amount: 4.5)

      campaign.valid?

      expect(campaign.errors[:starting_point].any? {|i| i.include?("be an integer")}).to be_truthy

      expect(campaign.errors[:goal_amount].any? {|i| i.include?("be an integer")}).to be_truthy

      campaign = Campaign.new(:starting_point => '-5', goal_is_in_supporters: true, goal_amount: 4.5)

      campaign.valid?

      expect(campaign.errors[:starting_point].any? {|i| i.include?("greater than or equal to 0")}).to be_truthy
    end


  end

  describe 'sends correct email based on type of campaign' do
    let(:nonprofit) { force_create(:nonprofit)}
    let(:parent_campaign) { force_create(:campaign, name: 'Parent campaign', nonprofit: nonprofit) }
    let(:child_campaign) do
      force_create(:campaign,
                   name: 'Child campaign',
                   parent_campaign_id: parent_campaign.id,
                   slug: "twehotiheiotheiofnieoth",
                   goal_amount_dollars: "1000", nonprofit: nonprofit )
    end

    it 'parent campaign sends out general campaign email' do
      expect { parent_campaign }.to change { ActionMailer::Base.deliveries.count }.by(1)
      expect(ActionMailer::Base.deliveries.last.body.include?("Create one-time or recurring")).to be_truthy
    end

    it 'child campaign sends out federated campaign email' do
      expect { child_campaign}.to change { ActionMailer::Base.deliveries.count }.by(2)
      expect(ActionMailer::Base.deliveries.last.body.include?("including a testimonial")).to be_truthy
    end
  end
end
