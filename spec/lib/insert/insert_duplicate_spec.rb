# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

describe InsertDuplicate do
  before(:all) {
    Timecop.freeze(2020, 5, 5)
  }

  after(:all) {
    Timecop.return
  }
  let(:nonprofit) { force_create(:nonprofit) }
  let(:profile) { force_create(:profile) }
  let(:dates) {
    {
      ten_days_from_now: DateTime.new(2020, 5, 15),
      ten_days_from_now_plus_4_hours: DateTime.new(2020, 5, 15, 4),
      two_days_from_now: DateTime.new(2020, 5, 7),
      two_days_from_now_plus_4_hours: DateTime.new(2020, 5, 7, 4),
      two_days_ago: DateTime.new(2020, 5, 3),
      two_days_ago_plus_4_hours: DateTime.new(2020, 5, 3, 4)
    }
  }

  describe ".campaign" do
    def set_campaign_date(end_date)
      @end_date = end_date
    end

    before(:each) {
      set_campaign_date(dates[:ten_days_from_now])
    }
    let(:campaign) { force_create(:campaign, name: campaign_name, nonprofit: nonprofit, end_datetime: @end_date, slug: campaign_slug, goal_amount: 20000, published: true, profile: profile) }

    let(:campaign_gift_option) { force_create(:campaign_gift_option, name: cgo_name, campaign: campaign) }
    let(:cgo_name) { "cgo name" }
    let(:campaign_name) { "campaign_name is so long that it must be shortened down" }
    let(:copy_name) { "campaign_name is so long that it must b (2020-05-05 copy) 00" }
    let(:campaign_slug) { "campaign_slug" }
    let(:copy_slug) { "campaign_slug_copy_00" }
    let(:common_result_attributes) {
      {
        nonprofit_id: nonprofit.id,
        parent_campaign_id: nil,
        reason_for_supporting: nil,
        profile_id: profile.id,
        background_image: nil,
        widget_description_id: nil,
        body: nil,
        created_at: Time.now,
        deleted: false,
        goal_amount: 20000,
        hide_activity_feed: nil,
        hide_custom_amounts: nil,
        hide_goal: nil,
        hide_thermometer: nil,
        hide_title: nil,
        main_image: nil,
        published: false,
        receipt_message: nil,
        show_recurring_amount: false,
        show_total_count: true,
        show_total_raised: true,
        summary: nil,
        tagline: nil,
        total_raised: nil,
        total_supporters: 1,
        updated_at: Time.now,
        url: nil,
        video_url: nil,
        vimeo_video_id: nil,
        youtube_video_id: nil,
        starting_point: 0,
        goal_is_in_supporters: nil,
        banner_image: nil,
        default_reason_for_supporting: nil,
        name: copy_name,

        slug: copy_slug,
        external_identifier: nil

      }.with_indifferent_access
    }

    describe "param validation" do
      it "does basic validation" do
        expect { InsertDuplicate.campaign(nil, nil) }.to(raise_error { |error|
          expect(error).to be_a ParamValidation::ValidationError
          expect_validation_errors(error.data, [{key: :campaign_id, name: :required},
            {key: :campaign_id, name: :is_integer},
            {key: :profile_id, name: :required},
            {key: :profile_id, name: :is_integer}])
        })
      end

      it "does campaign existence validation" do
        expect { InsertDuplicate.campaign(999, 999) }.to(raise_error { |error|
          expect(error).to be_a ParamValidation::ValidationError
          expect_validation_errors(error.data, [{key: :campaign_id}])
        })
      end

      it "does profile existence validation" do
        expect { InsertDuplicate.campaign(campaign.id, 999) }.to(raise_error { |error|
          expect(error).to be_a ParamValidation::ValidationError
          expect_validation_errors(error.data, [{key: :profile_id}])
        })
      end
    end
    it "copies a nonending campaign properly" do
      set_campaign_date(nil)
      campaign_gift_option
      result = InsertDuplicate.campaign(campaign.id, profile.id)
      expect(Campaign.count).to eq 2

      expect(result.attributes.with_indifferent_access).to eq(common_result_attributes.merge(
        {
          id: result.id,
          end_datetime: nil,
          banner_image: nil
        }
      ).with_indifferent_access)
      validate_cgo(result)
    end

    it "copies a soon to finish campaign properly" do
      set_campaign_date(dates[:two_days_from_now])
      campaign_gift_option
      result = InsertDuplicate.campaign(campaign.id, profile.id)
      expect(Campaign.count).to eq 2

      expect(result.attributes.with_indifferent_access).to eq(common_result_attributes.merge(
        {
          id: result.id,

          end_datetime: Time.utc(2020, 5, 12)

        }
      ).with_indifferent_access)
      validate_cgo(result)
    end

    it "copies a finished campaign properly" do
      set_campaign_date(dates[:two_days_ago])
      campaign_gift_option
      result = InsertDuplicate.campaign(campaign.id, profile.id)
      expect(Campaign.count).to eq 2
      expect(result.attributes.with_indifferent_access).to eq(common_result_attributes.merge(
        {
          id: result.id,

          end_datetime: Time.utc(2020, 5, 12)

        }
      ).with_indifferent_access)

      validate_cgo(result)
    end

    it "copies a future campaign properly" do
      campaign_gift_option
      result = InsertDuplicate.campaign(campaign.id, profile.id)
      expect(Campaign.count).to eq 2

      expect(result.attributes.with_indifferent_access).to eq(common_result_attributes.merge(
        {
          id: result.id,
          end_datetime: campaign.end_datetime.to_time
        }
      ).with_indifferent_access)
      validate_cgo(result)
    end

    def validate_cgo(new_campaign)
      old_campaign = campaign
      expect(CampaignGiftOption.count).to eq 2
      old_cgo = old_campaign.campaign_gift_options.first
      new_cgo = new_campaign.campaign_gift_options.first
      expect(old_cgo.id).to_not eq new_cgo.id
      expect(old_cgo.campaign_id).to_not eq new_cgo.campaign_id
      expect(old_cgo.attributes.except("id", "campaign_id")).to eq new_cgo.attributes.except("id", "campaign_id")
    end
  end

  describe ".event" do
    def set_event_start_time(start_time, end_time)
      @start_time = start_time
      @end_time = end_time
    end

    before(:each) {
      set_event_start_time(dates[:ten_days_from_now], dates[:ten_days_from_now_plus_4_hours])
      allow_any_instance_of(Event).to receive(:geocode).and_return(nil)
    }

    let(:event) {
      force_create(:event, name: event_name, nonprofit: nonprofit, start_datetime: @start_time, end_datetime: @end_time, slug: event_slug, published: true, profile: profile)
    }

    let(:ticket_level) { force_create(:ticket_level, name: ticket_level_name, amount_dollars: 500, event: event) }
    let(:event_discount) { force_create(:event_discount, code: "code", event: event) }
    let(:cgo_name) { "cgo name" }
    let(:ticket_level_name) { "cgo name" }
    let(:event_name) { "campaign_name is so long that it must be shortened down" }
    let(:copy_name) { "campaign_name is so long that it must b (2020-05-05 copy) 00" }
    let(:event_slug) { "campaign_slug" }
    let(:copy_slug) { "campaign_slug_copy_00" }
    let(:common_result_attributes) {
      {
        nonprofit_id: nonprofit.id,
        profile_id: profile.id,
        background_image: nil,
        body: nil,
        created_at: Time.now,
        deleted: false,
        hide_activity_feed: nil,
        hide_title: nil,
        main_image: nil,
        published: false,
        receipt_message: nil,
        summary: nil,
        tagline: nil,
        total_raised: 0,
        updated_at: Time.now,
        name: copy_name,
        slug: copy_slug,
        address: "100 N Appleton St",
        city: "Appleton",
        directions: nil,
        latitude: nil,
        location: nil,
        longitude: nil,
        organizer_email: profile.user.email,
        state_code: "WI",
        venue_name: nil,
        zip_code: nil,
        show_total_count: false,

        show_total_raised: false,

        in_person_or_virtual: "in_person"
      }.with_indifferent_access
    }

    describe "param validation" do
      it "does basic validation" do
        expect { InsertDuplicate.event(nil, nil) }.to(raise_error { |error|
          expect(error).to be_a ParamValidation::ValidationError
          expect_validation_errors(error.data, [{key: :event_id, name: :required},
            {key: :event_id, name: :is_integer},
            {key: :profile_id, name: :required},
            {key: :profile_id, name: :is_integer}])
        })
      end

      it "does event existence validation" do
        expect { InsertDuplicate.event(999, 999) }.to(raise_error { |error|
          expect(error).to be_a ParamValidation::ValidationError
          expect_validation_errors(error.data, [{key: :event_id}])
        })
      end

      it "does profile existence validation" do
        expect { InsertDuplicate.event(event.id, 999) }.to(raise_error { |error|
          expect(error).to be_a ParamValidation::ValidationError
          expect_validation_errors(error.data, [{key: :profile_id}])
        })
      end
    end

    it "copies a soon to start event properly" do
      set_event_start_time(dates[:two_days_from_now], dates[:two_days_from_now_plus_4_hours])
      ticket_level
      event_discount

      result = InsertDuplicate.event(event.id, profile.id)
      expect(Event.count).to eq 2
      result.attributes["start_datetime"] = result.attributes["start_datetime"].to_datetime
      result.attributes["end_datetime"] = result.attributes["end_datetime"].to_datetime
      expect(result.attributes.with_indifferent_access).to eq(common_result_attributes.merge(
        {
          id: result.id,
          start_datetime: DateTime.new(2020, 5, 12),
          end_datetime: DateTime.new(2020, 5, 12, 4)
        }
      ).with_indifferent_access)
      validate_tls(result)
      validate_eds(result)
    end

    it "copies a finished event properly" do
      set_event_start_time(dates[:two_days_ago], dates[:two_days_ago_plus_4_hours])
      ticket_level
      event_discount
      result = InsertDuplicate.event(event.id, profile.id)
      expect(Event.count).to eq 2

      result.attributes["start_datetime"] = result.attributes["start_datetime"]

      result.attributes["end_datetime"] = result.attributes["end_datetime"].to_datetime
      expect(result.attributes.with_indifferent_access).to eq(common_result_attributes.merge(
        {
          id: result.id,

          start_datetime: Time.utc(2020, 5, 12),
          end_datetime: Time.utc(2020, 5, 12, 4)

        }
      ).with_indifferent_access)

      validate_tls(result)
      validate_eds(result)
    end

    it "copies a future event properly" do
      ticket_level
      event_discount
      result = InsertDuplicate.event(event.id, profile.id)
      expect(Event.count).to eq 2
      result.attributes["start_datetime"] = result.attributes["start_datetime"].to_datetime
      result.attributes["end_datetime"] = result.attributes["end_datetime"].to_datetime
      expect(result.attributes.with_indifferent_access).to eq(common_result_attributes.merge(
        {
          id: result.id,
          start_datetime: event.start_datetime.to_time,
          end_datetime: event.end_datetime.to_time
        }
      ).with_indifferent_access)
      validate_tls(result)
      validate_eds(result)
    end

    it "copies an event with virtual" do
      event.in_person_or_virtual = "virtual"
      event.address = nil
      event.city = nil
      event.state_code = nil

      event.save!

      result = InsertDuplicate.event(event.id, profile.id)

      expect(result).to be_persisted
      expect(result).to be_virtual
      expect(result.address).to be_nil
      expect(result.city).to be_nil
      expect(result.state_code).to be_nil
    end

    context "when there are misc_event_infos to be copied" do
      before do
        event.create_misc_event_info
        event.misc_event_info.custom_get_tickets_button_label = "Giving Options"
        event.misc_event_info.save!
      end
      subject { InsertDuplicate.event(event.id, profile.id) }
      it "copies custom_get_tickets_button_label from misc_event_info" do
        expect(subject.misc_event_info.custom_get_tickets_button_label).to eq("Giving Options")
      end
    end

    def validate_tls(new_event)
      old_event = event
      expect(TicketLevel.count).to eq 2
      old_tl = old_event.ticket_levels.first
      new_tl = new_event.ticket_levels.first
      expect(old_tl.id).to_not eq new_tl.id
      expect(old_tl.event_id).to_not eq new_tl.event_id
      expect(old_tl.attributes.except("id", "event_id")).to eq(new_tl.attributes.except("id", "event_id"))
    end

    def validate_eds(new_event)
      old_event = event
      expect(EventDiscount.count).to eq 2
      old_tl = old_event.event_discounts.first
      new_tl = new_event.event_discounts.first
      expect(old_tl.id).to_not eq new_tl.id
      expect(old_tl.event_id).to_not eq new_tl.event_id
      expect(old_tl.attributes.except("id", "event_id")).to eq(new_tl.attributes.except("id", "event_id"))
    end
  end
end
