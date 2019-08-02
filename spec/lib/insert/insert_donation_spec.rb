# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'

describe InsertDonation do
  describe '.with_stripe' do
    before(:each) do
      Settings.payment_provider.stripe_connect = true
    end

    after(:each) do
      Settings.reload!
    end

    include_context :shared_rd_donation_value_context

    describe 'param validation' do
      it 'does basic validation' do
        validation_basic_validation { InsertDonation.with_stripe(designation: 34_124, dedication: 35_141, event_id: 'bad', campaign_id: 'bad') }
      end

      it 'errors out if token is invalid' do
        validation_invalid_token { InsertDonation.with_stripe(amount: 1, nonprofit_id: 1, supporter_id: 1, token: fake_uuid) }
      end

      it 'errors out if token is unauthorized' do
        validation_unauthorized { InsertDonation.with_stripe(amount: charge_amount, nonprofit_id: 1, supporter_id: 1, token: fake_uuid) }
      end

      it 'errors out if token is expired' do
        validation_expired { InsertDonation.with_stripe(amount: charge_amount, nonprofit_id: 1, supporter_id: 1, token: fake_uuid) }
      end

      describe 'errors during find if' do
        it 'supporter is invalid' do
          find_error_supporter { InsertDonation.with_stripe(amount: charge_amount, nonprofit_id: nonprofit.id, supporter_id: 55_555, token: source_token.token) }
        end

        it 'nonprofit is invalid' do
          find_error_nonprofit { InsertDonation.with_stripe(amount: charge_amount, nonprofit_id: 55_555, supporter_id: supporter.id, token: source_token.token) }
        end

        it 'campaign is invalid' do
          find_error_campaign { InsertDonation.with_stripe(amount: charge_amount, nonprofit_id: nonprofit.id, supporter_id: supporter.id, token: source_token.token, campaign_id: 5555) }
        end

        it 'event is invalid' do
          find_error_event { InsertDonation.with_stripe(amount: charge_amount, nonprofit_id: nonprofit.id, supporter_id: supporter.id, token: source_token.token, event_id: 5555) }
        end

        it 'profile is invalid' do
          find_error_profile { InsertDonation.with_stripe(amount: charge_amount, nonprofit_id: nonprofit.id, supporter_id: supporter.id, token: source_token.token, profile_id: 5555) }
        end
      end

      describe 'errors during relationship comparison if' do
        it 'supporter is deleted' do
          validation_supporter_deleted { InsertDonation.with_stripe(amount: charge_amount, nonprofit_id: nonprofit.id, supporter_id: supporter.id, token: source_token.token) }
        end

        it 'event is deleted' do
          validation_event_deleted { InsertDonation.with_stripe(amount: charge_amount, nonprofit_id: nonprofit.id, supporter_id: supporter.id, token: source_token.token, event_id: event.id) }
        end

        it 'campaign is deleted' do
          validation_campaign_deleted { InsertDonation.with_stripe(amount: charge_amount, nonprofit_id: nonprofit.id, supporter_id: supporter.id, token: source_token.token, campaign_id: campaign.id) }
        end

        it 'supporter doesnt belong to nonprofit' do
          validation_supporter_not_with_nonprofit { InsertDonation.with_stripe(amount: charge_amount, nonprofit_id: nonprofit.id, supporter_id: other_nonprofit_supporter.id, token: source_token.token) }
        end

        it 'campaign doesnt belong to nonprofit' do
          validation_campaign_not_with_nonprofit { InsertDonation.with_stripe(amount: charge_amount, nonprofit_id: nonprofit.id, supporter_id: supporter.id, token: source_token.token, campaign_id: other_campaign.id) }
        end

        it 'event doesnt belong to nonprofit' do
          validation_event_not_with_nonprofit { InsertDonation.with_stripe(amount: charge_amount, nonprofit_id: nonprofit.id, supporter_id: supporter.id, token: source_token.token, event_id: other_event.id) }
        end

        it 'card doesnt belong to supporter' do
          validation_card_not_with_supporter { InsertDonation.with_stripe(amount: charge_amount, nonprofit_id: nonprofit.id, supporter_id: supporter.id, token: other_source_token.token) }
        end
      end
    end

    it 'charge returns failed' do
      handle_charge_failed { InsertDonation.with_stripe(amount: charge_amount, nonprofit_id: nonprofit.id, supporter_id: supporter.id, token: source_token.token) }
    end

    describe 'success' do
      before(:each) do
        before_each_success
      end
      it 'process event donation' do
        process_event_donation { InsertDonation.with_stripe(amount: charge_amount, nonprofit_id: nonprofit.id, supporter_id: supporter.id, token: source_token.token, event_id: event.id, date: (Time.now + 1.day).to_s, dedication: 'dedication', designation: 'designation') }
      end

      it 'process campaign donation' do
        process_campaign_donation { InsertDonation.with_stripe(amount: charge_amount, nonprofit_id: nonprofit.id, supporter_id: supporter.id, token: source_token.token, campaign_id: campaign.id, date: (Time.now + 1.day).to_s, dedication: 'dedication', designation: 'designation') }
      end

      it 'processes general donation' do
        process_general_donation { InsertDonation.with_stripe(amount: charge_amount, nonprofit_id: nonprofit.id, supporter_id: supporter.id, token: source_token.token, profile_id: profile.id, date: (Time.now + 1.day).to_s, dedication: 'dedication', designation: 'designation') }
      end
    end
  end

  describe '#with_sepa' do
    # let!(:nonprofit) { Nonprofit.create(name: 'new', city: 'NY', state_code: 'NY') }
    # let(:supporter) { Supporter.create(nonprofit: nonprofit) }
    # let(:direct_debit) { DirectDebitDetail.create(supporter_id: supporter.id, account_holder_name: 'name', iban: 'de1234561234561234', bic: 'yxz') }
    # let(:data) do
    #   {
    #     'amount' => 2000,
    #     'supporter_id' => supporter.id,
    #     'nonprofit_id' => nonprofit.id,
    #     'recurring' => false,
    #     'direct_debit_detail_id' => direct_debit.id
    #   }
    # end
    include_context :shared_rd_donation_value_context

    describe 'saves donation' do
      before(:each) do
        before_each_sepa_success
      end
      it 'process event donation' do
        process_event_donation(sepa: true) { InsertDonation.with_sepa(amount: charge_amount, nonprofit_id: nonprofit.id, supporter_id: supporter.id, direct_debit_detail_id: direct_debit_detail.id, event_id: event.id, date: (Time.now + 1.day).to_s, dedication: 'dedication', designation: 'designation') }
      end

      it 'process campaign donation' do
        process_campaign_donation(sepa: true) { InsertDonation.with_sepa(amount: charge_amount, nonprofit_id: nonprofit.id, supporter_id: supporter.id, direct_debit_detail_id: direct_debit_detail.id, campaign_id: campaign.id, date: (Time.now + 1.day).to_s, dedication: 'dedication', designation: 'designation') }
      end

      it 'processes general donation' do
        process_general_donation(sepa: true) { InsertDonation.with_sepa(amount: charge_amount, nonprofit_id: nonprofit.id, supporter_id: supporter.id, direct_debit_detail_id: direct_debit_detail.id, profile_id: profile.id, date: (Time.now + 1.day).to_s, dedication: 'dedication', designation: 'designation') }
      end
    end
  end
  #   it 'saves donation' do
  #     expect { InsertDonation.with_sepa(data) }.to change(Donation, :count).by(1)
  #   end
  #
  #   it 'returns a json hash' do
  #     result = InsertDonation.with_sepa(data)
  #
  #     expect(result).to be_a(Hash)
  #     expect(result[:json]['donation']).to include data
  #   end
  # end

  it '.offsite', pending: true do
    raise
  end
end
