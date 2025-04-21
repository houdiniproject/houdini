# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"

describe CreateCampaignGift do
  describe ".create" do
    describe "param validation" do
      let(:donation) { force_create(:donation) }

      it "basic validation" do
        expect { CreateCampaignGift.create({}) }.to(raise_error do |error|
          expect(error).to be_a(ParamValidation::ValidationError)
          expect_validation_errors(error.data, [{
            key: :campaign_gift_option_id,
            name: :required
          },
            {
              key: :campaign_gift_option_id,
              name: :is_integer
            },
            {
              key: :donation_id,
              name: :required
            },
            {
              key: :donation_id,
              name: :is_integer
            }])
        end)
      end

      it "validates donation exists" do
        expect { CreateCampaignGift.create(donation_id: 555, campaign_gift_option_id: 5555) }.to(raise_error do |error|
                                                                                                   expect(error).to be_a(ParamValidation::ValidationError)
                                                                                                   expect_validation_errors(error.data, key: :donation_id)
                                                                                                   expect(error.message).to eq "555 is not a valid donation id."
                                                                                                 end)
      end

      it "validates campaign gift option exists" do
        expect { CreateCampaignGift.create(donation_id: donation.id, campaign_gift_option_id: 5555) }.to(raise_error do |error|
          expect(error).to be_a(ParamValidation::ValidationError)
          expect_validation_errors(error.data, key: :campaign_gift_option_id)
          expect(error.message).to eq "5555 is not a valid campaign gift option"
        end)
      end

      describe "donation and campaign gift option exist so we validate the details" do
        let(:profile) { force_create(:profile, user: force_create(:user)) }
        let(:nonprofit) { force_create(:nm_justice) }
        let(:campaign) { force_create(:campaign, profile: profile, nonprofit: nonprofit) }
        let(:bad_campaign) { force_create(:campaign, profile: profile, nonprofit: nonprofit) }

        it "rejects adding multiple gift options" do
          donation = force_create(:donation)
          campaign_gift_option = force_create(:campaign_gift_option, campaign: campaign)

          force_create(:campaign_gift, donation: donation)
          expect { CreateCampaignGift.create(donation_id: donation.id, campaign_gift_option_id: campaign_gift_option.id) }.to raise_error { |error|
            expect(error).to be_a(ParamValidation::ValidationError)
            expect_validation_errors(error.data, key: :donation_id)
            expect(error.message).to eq "#{donation.id} already has at least one associated campaign gift"
          }
        end

        it "rejects adding a gift option when the gift option campaign and donation campaign dont match" do
          donation = force_create(:donation, campaign: campaign)
          campaign_gift_option = force_create(:campaign_gift_option, campaign: bad_campaign)
          profile
          campaign
          bad_campaign

          expect { CreateCampaignGift.create(donation_id: donation.id, campaign_gift_option_id: campaign_gift_option.id) }.to raise_error { |error|
            expect(error).to be_a(ParamValidation::ValidationError)
            expect_validation_errors(error.data, key: :campaign_gift_option_id)
            expect(error.message).to eq "#{campaign_gift_option.id} is not for the same campaign as donation #{donation.id}"
          }
        end

        it "rejects associations when the donation amount is too low" do
          donation = force_create(:donation, campaign: campaign, amount: 299)
          campaign_gift_option = force_create(:campaign_gift_option, campaign: campaign, amount_one_time: 300, name: "name")
          expect {
            expect { CreateCampaignGift.create(donation_id: donation.id, campaign_gift_option_id: campaign_gift_option.id) }.to raise_error { |error|
              expect(error).to be_a(ParamValidation::ValidationError)
              expect_validation_errors(error.data, key: :campaign_gift_option_id)
              expect(error.message).to eq "#{campaign_gift_option.id} gift options requires a donation of 300 for donation #{donation.id}"
            }
          }.to have_enqueued_job(AdminFailedGiftJob).with(donation, campaign_gift_option)
        end

        it "rejects associations when the recurring donation amount is too low" do
          donation = force_create(:donation, campaign: campaign, amount: 299, recurring: true)
          force_create(:recurring_donation, amount: 299, donation: donation)
          campaign_gift_option = force_create(:campaign_gift_option, campaign: campaign, amount_recurring: 300, name: "name")

          expect {
            expect { CreateCampaignGift.create(donation_id: donation.id, campaign_gift_option_id: campaign_gift_option.id) }.to raise_error { |error|
              expect(error).to be_a(ParamValidation::ValidationError)
              expect_validation_errors(error.data, key: :campaign_gift_option_id)
              expect(error.message).to eq "#{campaign_gift_option.id} gift options requires a recurring donation of 300 for donation #{donation.id}"
            }
          }.to have_enqueued_job(AdminFailedGiftJob).with(donation, campaign_gift_option)
        end

        it "rejects association when the there are no gifts available" do
          donation = force_create(:donation, campaign: campaign, amount: 300, recurring: true)
          force_create(:recurring_donation, amount: 300, donation: donation)

          campaign_gift_option = force_create(:campaign_gift_option, campaign: campaign, amount_recurring: 300, quantity: 1)

          force_create(:campaign_gift, campaign_gift_option: campaign_gift_option)

          expect {
            expect { CreateCampaignGift.create(donation_id: donation.id, campaign_gift_option_id: campaign_gift_option.id) }.to raise_error { |error|
              expect(error).to be_a(ParamValidation::ValidationError)
              expect_validation_errors(error.data, [{key: :campaign_gift_option_id}])
              expect(error.message).to eq "#{campaign_gift_option.id} has no more inventory"
              expect(CampaignGift.count).to eq 1
            }
          }.to have_enqueued_job(AdminFailedGiftJob).with(donation, campaign_gift_option)
        end
      end
    end

    describe "successful insert" do
      let(:profile) { force_create(:profile, user: force_create(:user)) }
      let(:nonprofit) { create(:nm_justice) }
      let(:campaign) { force_create(:campaign, profile: profile, nonprofit: nonprofit) }

      describe "insert with no option quantity limit" do
        let(:campaign_gift_option) { force_create(:campaign_gift_option, campaign: campaign, amount_recurring: 300, amount_one_time: 5000) }

        it "inserts non_recurring properly" do
          Timecop.freeze(2020, 4, 5) do
            donation = force_create(:donation, campaign: campaign, amount: 5000)
            result = CreateCampaignGift.create(donation_id: donation.id, campaign_gift_option_id: campaign_gift_option.id)
            expected = {donation_id: donation.id, campaign_gift_option_id: campaign_gift_option.id, created_at: Time.now, updated_at: Time.now, id: result.id, recurring_donation_id: nil}.with_indifferent_access
            expect(result.attributes).to eq expected
            expect(CampaignGift.first.attributes).to eq expected
            expect(Campaign.count).to eq 1
          end
        end

        it "inserts recurring properly" do
          Timecop.freeze(2020, 4, 5) do
            donation = force_create(:donation, campaign: campaign, amount: 300)
            force_create(:recurring_donation, amount: 300, donation: donation)
            result = CreateCampaignGift.create(donation_id: donation.id, campaign_gift_option_id: campaign_gift_option.id)
            expected = {donation_id: donation.id, campaign_gift_option_id: campaign_gift_option.id, created_at: Time.now, updated_at: Time.now, id: result.id, recurring_donation_id: nil}.with_indifferent_access
            expect(result.attributes).to eq expected
            expect(CampaignGift.first.attributes).to eq expected
            expect(Campaign.count).to eq 1
          end
        end
      end

      describe "insert when option quantity is 0" do
        let(:campaign_gift_option) { force_create(:campaign_gift_option, campaign: campaign, amount_recurring: 300, amount_one_time: 5000, quantity: 0) }

        it "inserts non_recurring properly" do
          Timecop.freeze(2020, 4, 5) do
            donation = force_create(:donation, campaign: campaign, amount: 5000)
            result = CreateCampaignGift.create(donation_id: donation.id, campaign_gift_option_id: campaign_gift_option.id)
            expected = {donation_id: donation.id, campaign_gift_option_id: campaign_gift_option.id, created_at: Time.now, updated_at: Time.now, id: result.id, recurring_donation_id: nil}.with_indifferent_access
            expect(result.attributes).to eq expected
            expect(CampaignGift.first.attributes).to eq expected
            expect(Campaign.count).to eq 1
          end
        end

        it "inserts recurring properly" do
          Timecop.freeze(2020, 4, 5) do
            donation = force_create(:donation, campaign: campaign, amount: 300)
            force_create(:recurring_donation, amount: 300, donation: donation)
            result = CreateCampaignGift.create(donation_id: donation.id, campaign_gift_option_id: campaign_gift_option.id)
            expected = {donation_id: donation.id, campaign_gift_option_id: campaign_gift_option.id, created_at: Time.now, updated_at: Time.now, id: result.id, recurring_donation_id: nil}.with_indifferent_access
            expect(result.attributes).to eq expected
            expect(CampaignGift.first.attributes).to eq expected
            expect(Campaign.count).to eq 1
          end
        end
      end

      describe "insert when option inventory is less than quantity total" do
        let(:campaign_gift_option) { force_create(:campaign_gift_option, campaign: campaign, amount_recurring: 300, amount_one_time: 5000, quantity: 1) }

        it "inserts non_recurring properly" do
          Timecop.freeze(2020, 4, 5) do
            donation = force_create(:donation, campaign: campaign, amount: 5000)
            result = CreateCampaignGift.create(donation_id: donation.id, campaign_gift_option_id: campaign_gift_option.id)
            expected = {donation_id: donation.id, campaign_gift_option_id: campaign_gift_option.id, created_at: Time.now, updated_at: Time.now, id: result.id, recurring_donation_id: nil}.with_indifferent_access
            expect(result.attributes).to eq expected
            expect(CampaignGift.first.attributes).to eq expected
            expect(Campaign.count).to eq 1
          end
        end

        it "inserts recurring properly" do
          Timecop.freeze(2020, 4, 5) do
            donation = force_create(:donation, campaign: campaign, amount: 300)
            force_create(:recurring_donation, amount: 300, donation: donation)
            result = CreateCampaignGift.create(donation_id: donation.id, campaign_gift_option_id: campaign_gift_option.id)
            expected = {donation_id: donation.id, campaign_gift_option_id: campaign_gift_option.id, created_at: Time.now, updated_at: Time.now, id: result.id, recurring_donation_id: nil}.with_indifferent_access
            expect(result.attributes).to eq expected
            expect(CampaignGift.first.attributes).to eq expected
            expect(Campaign.count).to eq 1
          end
        end
      end
    end
  end
end
