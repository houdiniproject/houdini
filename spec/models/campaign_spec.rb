# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"
require "carrierwave/test/matchers"
def get_attributes_which_should_be_updated_keys
  %w[
    tagline body video_url receipt_message youtube_video_id summary vimeo_video_id
  ]
end

def get_attributes_which_should_not_be_updated_keys
  %w[
    slug goal_amount nonprofit_id profile_id show_total_raised
    show_total_count hide_activity_feed deleted hide_title
    hide_thermometer hide_goal
    hide_custom_amounts show_recurring_amount
    end_datetime external_identifier goal_is_in_supporters starting_point
    reason_for_supporting
  ]
end

def get_uploader_attribute_keys
  %w[
    main_image background_image banner_image
  ]
end
RSpec.describe Campaign, type: :model do
  include CarrierWave::Test::Matchers

  it { is_expected.to belong_to :widget_description }

  describe "goal_amount" do
    before(:each) do
      @nonprofit = create(:nonprofit)
    end

    it "when goal_is_in_supporters = true validate starting point and goal_amount" do
      campaign = Campaign.new(starting_point: "ethwohgniu", goal_is_in_supporters: true)

      campaign.valid?

      expect(campaign.errors[:starting_point].any? { |i| i.include?("not a number") }).to be_truthy

      ["can't be blank", "not a number", "greater than or equal to 1"].each do |expected|
        expect(campaign.errors[:goal_amount].any? { |i| i.include?(expected) }).to be_truthy
      end

      campaign = Campaign.new(starting_point: "1.3", goal_is_in_supporters: true, goal_amount: 4.5)

      campaign.valid?

      expect(campaign.errors[:starting_point].any? { |i| i.include?("be an integer") }).to be_truthy

      expect(campaign.errors[:goal_amount].any? { |i| i.include?("be an integer") }).to be_truthy
    end

    it "when goal_is_in_supporters = false validate starting point and goal_amount" do
      campaign = Campaign.new(starting_point: "ethwohgniu", goal_is_in_supporters: false)

      campaign.valid?

      expect(campaign.errors[:starting_point].any? { |i| i.include?("not a number") }).to be_truthy

      ["can't be blank", "not a number", "greater than or equal to 99"].each do |expected|
        expect(campaign.errors[:goal_amount].any? { |i| i.include?(expected) }).to be_truthy
      end

      campaign = Campaign.new(starting_point: "1.3", goal_is_in_supporters: true, goal_amount: 4.5)

      campaign.valid?

      expect(campaign.errors[:starting_point].any? { |i| i.include?("be an integer") }).to be_truthy

      expect(campaign.errors[:goal_amount].any? { |i| i.include?("be an integer") }).to be_truthy

      campaign = Campaign.new(starting_point: "-5", goal_is_in_supporters: true, goal_amount: 4.5)

      campaign.valid?

      expect(campaign.errors[:starting_point].any? { |i| i.include?("greater than or equal to 0") }).to be_truthy
    end
  end

  describe "sends correct email based on type of campaign" do
    let(:nonprofit) { force_create(:nonprofit) }
    let(:parent_campaign) { force_create(:campaign, name: "Parent campaign", nonprofit: nonprofit) }
    let(:child_campaign) do
      force_create(:campaign,
        name: "Child campaign",
        parent_campaign_id: parent_campaign.id,
        slug: "twehotiheiotheiofnieoth",
        goal_amount_dollars: "1000", nonprofit: nonprofit)
    end

    let(:html_body) do
      ActionMailer::Base.deliveries.last.parts.select { |i| i.content_type.starts_with? "text/html" }.first.body
    end

    it "parent campaign sends out general campaign email" do
      expect { parent_campaign }.to change { ActionMailer::Base.deliveries.count }.by(1)
      expect(html_body.include?("Create one-time or recurring")).to be_truthy
    end

    it "child campaign sends out federated campaign email" do
      expect { child_campaign }.to change { ActionMailer::Base.deliveries.count }.by(2)
      expect(html_body.include?("including a testimonial")).to be_truthy
    end
  end

  describe "pausing" do
    describe "when no misc_campaign_info" do
      subject {
        force_create(:campaign)
      }

      it { is_expected.to_not be_paused }
    end

    describe "when misc_campaign_info exists but not paused" do
      subject do
        campaign = force_create(:campaign)
        campaign.create_misc_campaign_info
        campaign
      end

      it { is_expected.to_not be_paused }
    end

    describe "when misc_campaign_info exists and is paused" do
      subject do
        campaign = force_create(:campaign)
        campaign.create_misc_campaign_info(paused: true)
        campaign
      end

      it { is_expected.to be_paused }
    end
  end

  describe "#update_from_parent!" do
    let(:empty_campaign) { create(:empty_campaign) }
    let(:nonprofit) { empty_campaign.nonprofit }
    let(:campaign_with_things_set_1) { create(:campaign_with_things_set_1, nonprofit: nonprofit) }

    context "when the child is an empty campaign" do
      let(:parent_campaign) { campaign_with_things_set_1 }
      let(:original_campaign_attributes) {
        empty_campaign.attributes
      }

      before(:each) {
        original_campaign_attributes
        empty_campaign.parent_campaign = parent_campaign
        empty_campaign.save!
        empty_campaign.update_from_parent!
      }

      get_attributes_which_should_not_be_updated_keys.each do |key|
        it {
          expect(empty_campaign).to have_attributes(key => original_campaign_attributes[key])
        }
      end

      it {
        expect(empty_campaign).to have_attributes(parent_campaign_id: parent_campaign.id)
      }

      get_attributes_which_should_be_updated_keys.each do |key|
        it {
          expect(empty_campaign).to have_attributes(key => parent_campaign.attributes[key])
        }
      end

      get_uploader_attribute_keys.each do |key|
        it {
          expect(empty_campaign.send(key.to_sym).path).to be_identical_to(campaign_with_things_set_1.send(key.to_sym).path)
        }
      end
    end

    context "when child has something and parent does not" do
      let(:parent_campaign) { empty_campaign }
      let(:child_campaign) { campaign_with_things_set_1 }
      let(:original_campaign_attributes) {
        child_campaign.attributes
      }

      before(:each) {
        original_campaign_attributes
        child_campaign.parent_campaign = parent_campaign
        child_campaign.save!
        child_campaign.update_from_parent!
      }

      get_attributes_which_should_not_be_updated_keys.each do |key|
        it {
          expect(child_campaign).to have_attributes(key => original_campaign_attributes[key])
        }
      end

      it {
        expect(child_campaign).to have_attributes(parent_campaign_id: parent_campaign.id)
      }

      get_attributes_which_should_be_updated_keys.each do |key|
        it {
          expect(child_campaign).to have_attributes(key => parent_campaign.attributes[key])
        }
      end

      get_uploader_attribute_keys.each do |key|
        it {
          expect(child_campaign.send(key.to_sym).path).to be_nil
        }
      end
    end

    context "when child has something and parent has something different" do
      let(:parent_campaign) { campaign_with_things_set_1 }
      let(:child_campaign) {
        create(:campaign_with_things_set_2,
          parent_campaign_id: parent_campaign.id, nonprofit: parent_campaign.nonprofit)
      }
      let(:original_campaign_attributes) {
        child_campaign.attributes
      }

      before(:each) {
        child_campaign.update_from_parent!
      }

      get_attributes_which_should_not_be_updated_keys.each do |key|
        it {
          expect(child_campaign).to have_attributes(key => original_campaign_attributes[key])
        }
      end

      it {
        expect(child_campaign).to have_attributes(parent_campaign_id: parent_campaign.id)
      }

      get_attributes_which_should_be_updated_keys.each do |key|
        it {
          expect(child_campaign).to have_attributes(key => parent_campaign.attributes[key])
        }
      end

      get_uploader_attribute_keys.each do |key|
        it {
          expect(child_campaign.send(key.to_sym).path).to be_identical_to(parent_campaign.send(key.to_sym).path)
        }
      end
    end

    context "when child has something and parent has something similar" do
      let(:parent_campaign) { campaign_with_things_set_1 }
      let(:child_campaign) {
        create(:campaign_with_things_set_1,
          nonprofit_id: campaign_with_things_set_1.nonprofit.id,
          parent_campaign_id: parent_campaign.id, slug: "another-slug-of-slugs-1")
      }

      let(:original_campaign_attributes) {
        child_campaign.attributes
      }

      before(:each) {
        original_campaign_attributes
        child_campaign.update_from_parent!
      }

      get_attributes_which_should_not_be_updated_keys.each do |key|
        it {
          expect(child_campaign).to have_attributes(key => original_campaign_attributes[key])
        }
      end

      it {
        expect(child_campaign).to have_attributes(parent_campaign_id: parent_campaign.id)
      }

      get_attributes_which_should_be_updated_keys.each do |key|
        it {
          expect(child_campaign).to have_attributes(key => original_campaign_attributes[key])
        }
      end

      get_uploader_attribute_keys.each do |key|
        it {
          expect(child_campaign.send(key.to_sym).path).to be_identical_to(child_campaign.send(key.to_sym).path)
        }
      end
    end
  end

  describe ":after_update" do
    describe "with send_campaign_updated" do
      let(:parent_campaign) { create(:campaign_with_things_set_1) }

      let!(:child_campaign) {
        create(:campaign_with_things_set_1,
          nonprofit_id: parent_campaign.nonprofit.id,
          parent_campaign_id: parent_campaign.id, slug: "another-slug-of-slugs-1")
      }

      let!(:child_campaign_2) {
        create(:campaign_with_things_set_1,
          nonprofit_id: parent_campaign.nonprofit.id,
          parent_campaign_id: parent_campaign.id, slug: "another-slug-of-slugs-2")
      }

      it "queues CampaignUpdatedJob" do
        expect_job_queued.with(JobTypes::CampaignUpdatedJob, parent_campaign.id)
        parent_campaign.summary = "a new summary"
        parent_campaign.save!
      end

      it "updates child_campaign" do
        parent_campaign.summary = "a new summary"
        parent_campaign.save!

        child_campaign.reload

        expect(child_campaign.summary).to eq "a new summary"
      end

      it "updates child_campaign" do
        parent_campaign.summary = "a new summary"
        parent_campaign.save!

        child_campaign_2.reload

        expect(child_campaign_2.summary).to eq "a new summary"
      end
    end
  end

  describe "#fee_coverage_option" do
    let(:campaign) { build(:campaign, nonprofit: nonprofit) }

    let(:nonprofit) { build(:nonprofit, fee_coverage_option: "manual") }

    it "is set to nonprofit.fee_coverage_option when misc_campaign_info is not there" do
      expect(campaign.fee_coverage_option).to eq nonprofit.fee_coverage_option
    end

    it "is set to nonprofit.fee_coverage_option when misc_campaign_info.fee_coverage_option_config is nil" do
      campaign.misc_campaign_info = build(:misc_campaign_info, fee_coverage_option_config: nil)
      expect(campaign.fee_coverage_option).to eq nonprofit.fee_coverage_option
    end

    it "is set to manual when misc_campaign_info.fee_coverage_option_config is manual" do
      campaign.misc_campaign_info = build(:misc_campaign_info, fee_coverage_option_config: "manual")
      expect(campaign.fee_coverage_option).to eq "manual"
    end

    it "is set to auto when misc_campaign_info.fee_coverage_option_config is auto" do
      campaign.misc_campaign_info = build(:misc_campaign_info, fee_coverage_option_config: "auto")
      expect(campaign.fee_coverage_option).to eq "auto"
    end

    it "is set to none when misc np info fee_coverage_option_config is none" do
      campaign.misc_campaign_info = build(:misc_campaign_info, fee_coverage_option_config: "none")
      expect(campaign.fee_coverage_option).to eq "none"
    end
  end
end
