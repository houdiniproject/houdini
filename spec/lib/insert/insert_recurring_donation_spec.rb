# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

describe InsertRecurringDonation do
  describe ".with_stripe" do
    include_context :shared_rd_donation_value_context

    it "does basic validation" do
      validation_basic_validation { InsertRecurringDonation.with_stripe({designation: 34124, dedication: 35141, event_id: "bad", campaign_id: "bad"}) }
    end

    it "does recurring donation validation" do
      expect {
        InsertRecurringDonation.with_stripe(amount: 1, nonprofit_id: 1, supporter_id: 1, token: fake_uuid,
          recurring_donation: {interval: "not number", start_date: "not_date", time_unit: 4, paydate: "faf"})
      }.to raise_error { |e|
             expect(e).to be_a ParamValidation::ValidationError
             expect_validation_errors(e.data, [
               {key: :interval, name: :is_integer},
               {key: :start_date, name: :can_be_date},
               {key: :time_unit, name: :included_in},
               {key: :paydate, name: :is_integer}
             ])
           }
    end

    it "does paydate validation min" do
      expect {
        InsertRecurringDonation.with_stripe(amount: 1, nonprofit_id: 1, supporter_id: 1, token: fake_uuid,
          recurring_donation: {paydate: "0"})
      }.to raise_error { |e|
             expect(e).to be_a ParamValidation::ValidationError
             expect_validation_errors(e.data, [
               {key: :paydate, name: :min}
             ])
           }
    end

    it "does paydate validation max" do
      expect {
        InsertRecurringDonation.with_stripe(amount: 1, nonprofit_id: 1, supporter_id: 1, token: fake_uuid,
          recurring_donation: {paydate: "29"})
      }.to raise_error { |e|
             expect(e).to be_a ParamValidation::ValidationError
             expect_validation_errors(e.data, [
               {key: :paydate, name: :max}
             ])
           }
    end

    it "errors out if token is invalid" do
      validation_invalid_token { InsertRecurringDonation.with_stripe(amount: 1, nonprofit_id: 1, supporter_id: 1, token: fake_uuid) }
    end

    it "errors out if token is unauthorized" do
      validation_unauthorized { InsertRecurringDonation.with_stripe(amount: charge_amount, nonprofit_id: 1, supporter_id: 1, token: fake_uuid) }
    end

    it "errors out if token is expired" do
      validation_expired { InsertRecurringDonation.with_stripe(amount: charge_amount, nonprofit_id: 1, supporter_id: 1, token: fake_uuid) }
    end

    describe "errors during find if" do
      it "supporter is invalid" do
        find_error_supporter { InsertRecurringDonation.with_stripe(amount: charge_amount, nonprofit_id: nonprofit.id, supporter_id: 55555, token: source_token.token) }
      end

      it "nonprofit is invalid" do
        find_error_nonprofit { InsertRecurringDonation.with_stripe(amount: charge_amount, nonprofit_id: 55555, supporter_id: supporter.id, token: source_token.token) }
      end

      it "campaign is invalid" do
        find_error_campaign { InsertRecurringDonation.with_stripe(amount: charge_amount, nonprofit_id: nonprofit.id, supporter_id: supporter.id, token: source_token.token, campaign_id: 5555) }
      end

      it "event is invalid" do
        find_error_event { InsertRecurringDonation.with_stripe(amount: charge_amount, nonprofit_id: nonprofit.id, supporter_id: supporter.id, token: source_token.token, event_id: 5555) }
      end

      it "profile is invalid" do
        find_error_profile { InsertRecurringDonation.with_stripe(amount: charge_amount, nonprofit_id: nonprofit.id, supporter_id: supporter.id, token: source_token.token, profile_id: 5555) }
      end
    end

    describe "errors during relationship comparison if" do
      it "event is deleted" do
        validation_event_deleted { InsertRecurringDonation.with_stripe(amount: charge_amount, nonprofit_id: nonprofit.id, supporter_id: supporter.id, token: source_token.token, event_id: event.id) }
      end

      it "campaign is deleted" do
        validation_campaign_deleted { InsertRecurringDonation.with_stripe(amount: charge_amount, nonprofit_id: nonprofit.id, supporter_id: supporter.id, token: source_token.token, campaign_id: campaign.id) }
      end

      it "supporter is deleted" do
        validation_supporter_deleted { InsertRecurringDonation.with_stripe(amount: charge_amount, nonprofit_id: nonprofit.id, supporter_id: supporter.id, token: source_token.token) }
      end

      it "supporter doesnt belong to nonprofit" do
        validation_supporter_not_with_nonprofit { InsertRecurringDonation.with_stripe(amount: charge_amount, nonprofit_id: nonprofit.id, supporter_id: other_nonprofit_supporter.id, token: source_token.token) }
      end

      it "campaign doesnt belong to nonprofit" do
        validation_campaign_not_with_nonprofit { InsertRecurringDonation.with_stripe(amount: charge_amount, nonprofit_id: nonprofit.id, supporter_id: supporter.id, token: source_token.token, campaign_id: other_campaign.id) }
      end

      it "event doesnt belong to nonprofit" do
        validation_event_not_with_nonprofit { InsertRecurringDonation.with_stripe(amount: charge_amount, nonprofit_id: nonprofit.id, supporter_id: supporter.id, token: source_token.token, event_id: other_event.id) }
      end

      it "card doesnt belong to supporter" do
        validation_card_not_with_supporter { InsertRecurringDonation.with_stripe(amount: charge_amount, nonprofit_id: nonprofit.id, supporter_id: supporter.id, token: other_source_token.token) }
      end

      it "if nonprofit is unvetted" do
        find_error_nonprofit do
          nonprofit.update(vetted: false)
          InsertRecurringDonation.with_stripe(amount: charge_amount, nonprofit_id: nonprofit.id, supporter_id: supporter.id, token: other_source_token.token)
        end
      end
    end

    it "charge returns failed" do
      handle_charge_failed { InsertRecurringDonation.with_stripe(amount: charge_amount, nonprofit_id: nonprofit.id, supporter_id: supporter.id, token: source_token.token) }
    end

    describe "success" do
      before(:each) {
        allow(SecureRandom).to receive(:uuid).and_return(default_edit_token)
      }
      describe "charge happens" do
        before(:each) {
          before_each_success
        }
        it "process event donation" do
          process_event_donation(recurring_donation: {paydate: nil, interval: 1, time_unit: "year", start_date: Time.current.beginning_of_day}) {
            result = InsertRecurringDonation.with_stripe(amount: charge_amount, nonprofit_id: nonprofit.id, supporter_id: supporter.id, token: source_token.token, event_id: event.id, date: (Time.now + 1.day).to_s, dedication: "dedication", designation: "designation", recurring_donation: {time_unit: "year"}, fee_covered: false)

            p = Payment.find(result["payment"]["id"])
            rd = RecurringDonation.find(result["recurring_donation"]["id"])
            expect(p.misc_payment_info.fee_covered).to eq false
            expect(rd.misc_recurring_donation_info.fee_covered).to eq false
            result
          }
        end

        it "process campaign donation" do
          process_campaign_donation(recurring_donation: {paydate: nil, interval: 2, time_unit: "month", start_date: Time.current.beginning_of_day}) {
            result = InsertRecurringDonation.with_stripe(amount: charge_amount, nonprofit_id: nonprofit.id, supporter_id: supporter.id, token: source_token.token, campaign_id: campaign.id, date: (Time.now + 1.day).to_s, dedication: "dedication", designation: "designation", recurring_donation: {interval: 2}, fee_covered: true)

            p = Payment.find(result["payment"]["id"])
            rd = RecurringDonation.find(result["recurring_donation"]["id"])
            expect(p.misc_payment_info.fee_covered).to eq true
            expect(rd.misc_recurring_donation_info.fee_covered).to eq true
            result
          }
        end

        it "processes general donation with no recurring donation hash" do
          process_general_donation(recurring_donation: {paydate: Time.now.day, interval: 1, time_unit: "month", start_date: Time.now.beginning_of_day}) {
            result = InsertRecurringDonation.with_stripe(amount: charge_amount, nonprofit_id: nonprofit.id, supporter_id: supporter.id, token: source_token.token, profile_id: profile.id, date: Time.now.to_s, dedication: "dedication", designation: "designation")
            p = Payment.find(result["payment"]["id"])
            rd = RecurringDonation.find(result["recurring_donation"]["id"])
            expect(p.misc_payment_info.fee_covered).to be_nil
            expect(rd.misc_recurring_donation_info.fee_covered).to be_nil
            result
          }
        end
      end

      describe "future charge" do
        before(:each) {
          before_each_success(false)
        }

        it "processes general donation" do
          process_general_donation(expect_payment: false, expect_charge: false, recurring_donation: {paydate: (Time.now + 5.days).day, interval: 1, time_unit: "month", start_date: (Time.now + 5.days).beginning_of_day}) {
            result = InsertRecurringDonation.with_stripe(amount: charge_amount, nonprofit_id: nonprofit.id, supporter_id: supporter.id, token: source_token.token, profile_id: profile.id, date: (Time.now + 1.day).to_s, dedication: "dedication", designation: "designation",
              recurring_donation: {start_date: (Time.now + 5.days).to_s})

            rd = RecurringDonation.find(result["recurring_donation"]["id"])
            expect(rd.misc_recurring_donation_info.fee_covered).to be_nil
            result
          }
        end

        it "includes fee covering" do
          process_general_donation(expect_payment: false, expect_charge: false, recurring_donation: {paydate: (Time.now + 5.days).day, interval: 1, time_unit: "month", start_date: (Time.now + 5.days).beginning_of_day}) {
            result = InsertRecurringDonation.with_stripe(amount: charge_amount, nonprofit_id: nonprofit.id, supporter_id: supporter.id, token: source_token.token, profile_id: profile.id, date: (Time.now + 1.day).to_s, dedication: "dedication", designation: "designation", recurring_donation: {start_date: (Time.now + 5.days).to_s}, fee_covered: true)

            rd = RecurringDonation.find(result["recurring_donation"]["id"])
            expect(rd.misc_recurring_donation_info.fee_covered).to eq true
            result
          }
        end
      end
    end
  end

  describe ".convert_donation_to_recurring_donation" do
    describe "wonderful testing Eric" do
      around(:each) do |ex|
        StripeMockHelper.mock do
          Timecop.freeze(2020, 4, 29) do
            ex.run
          end
        end
      end
      let(:nonprofit) { force_create(:nonprofit, state_code_slug: "wi", city_slug: "city", slug: "sluggster") }
      let(:profile) { force_create(:profile, user: force_create(:user)) }
      let(:supporter) { force_create(:supporter, nonprofit: nonprofit) }
      let(:card) { force_create(:card, holder: supporter) }
      let(:campaign) { force_create(:campaign, profile: profile, nonprofit: nonprofit) }
      let(:event) { force_create(:event, profile: profile, nonprofit: nonprofit) }
      let!(:donation) { force_create(:donation, nonprofit: nonprofit, supporter: supporter, amount: 4000, card: card, campaign: campaign, event: event) }
      let!(:payment) { force_create(:payment, donation: donation, kind: "Donation") }

      it "param validation" do
        expect { InsertRecurringDonation.convert_donation_to_recurring_donation(nil) }.to(raise_error { |error|
          expect(error).to be_a ParamValidation::ValidationError
          expect_validation_errors(error.data, [{key: :donation_id, name: :required}, {key: :donation_id, name: :is_integer}])
        })
      end

      it "rejects invalid donation" do
        expect { InsertRecurringDonation.convert_donation_to_recurring_donation(5555) }.to(raise_error { |error|
          expect(error).to be_a ParamValidation::ValidationError
          expect_validation_errors(error.data, [{key: :donation_id}])
        })
      end

      it "accepts proper information" do
        Timecop.freeze(2020, 5, 4) do
          rd = InsertRecurringDonation.convert_donation_to_recurring_donation(donation.id)
          # this needs some serious improvement
          expected_rd = {id: rd.id,
                         donation_id: donation.id,
                         nonprofit_id: nonprofit.id,
                         supporter_id: supporter.id,
                         updated_at: Time.now,
                         created_at: Time.now,
                         active: true,
                         n_failures: 0,
                         interval: 1,
                         time_unit: "month",
                         start_date: donation.created_at.beginning_of_day,
                         paydate: 28,
                         profile_id: nil,
                         cancelled_at: nil,
                         cancelled_by: nil,
                         amount: 4000,
                         anonymous: false,
                         card_id: nil,
                         campaign_id: nil,
                         failure_message: nil,
                         end_date: nil,
                         email: nil,
                         origin_url: nil}.with_indifferent_access

          expect(rd.attributes.except("edit_token")).to eq(expected_rd)

          expect(rd.edit_token).to_not be_falsey

          expect(rd.donation.recurring).to eq true
          expect(rd.donation.payment.kind).to eq "RecurringDonation"
        end
      end
    end

    describe "test for earlier in the month" do
      around(:each) do |ex|
        StripeMockHelper.mock do
          Timecop.freeze(2020, 4, 5) do
            ex.run
          end
        end
      end
      let(:nonprofit) { force_create(:nonprofit, state_code_slug: "wi", city_slug: "city", slug: "sluggster") }
      let(:profile) { force_create(:profile, user: force_create(:user)) }
      let(:supporter) { force_create(:supporter, nonprofit: nonprofit) }
      let(:card) { force_create(:card, holder: supporter) }
      let(:campaign) { force_create(:campaign, profile: profile, nonprofit: nonprofit) }
      let(:event) { force_create(:event, profile: profile, nonprofit: nonprofit) }

      let!(:donation) { force_create(:donation, nonprofit: nonprofit, supporter: supporter, amount: 4000, card: card, campaign: campaign, event: event) }
      let!(:payment) { force_create(:payment, donation: donation, kind: "Donation") }
      it "works when the date is earlier in the month" do
        Timecop.freeze(2020, 4, 29) do
          rd = InsertRecurringDonation.convert_donation_to_recurring_donation(donation.id)
          # this needs some serious improvement

          expected_rd = {id: rd.id,
                         donation_id: donation.id,
                         nonprofit_id: nonprofit.id,
                         supporter_id: supporter.id,
                         updated_at: Time.now,
                         created_at: Time.now,
                         active: true,
                         n_failures: 0,
                         interval: 1,
                         time_unit: "month",
                         start_date: donation.created_at.beginning_of_day,
                         paydate: 5,
                         profile_id: nil,
                         cancelled_at: nil,
                         cancelled_by: nil,
                         amount: 4000,
                         anonymous: false,
                         card_id: nil,
                         campaign_id: nil,
                         failure_message: nil,
                         end_date: nil,
                         email: nil,
                         origin_url: nil}.with_indifferent_access
          expect(rd.attributes.except("edit_token")).to eq(expected_rd)

          expect(rd.donation.recurring).to eq true
          expect(rd.donation.payment.kind).to eq "RecurringDonation"

          expect(rd.edit_token).to_not be_falsey
        end
      end
    end
  end
end
