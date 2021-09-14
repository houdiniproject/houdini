# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'

RSpec.describe Nonprofit, type: :model do

  it {is_expected.to validate_presence_of(:name)}
  
  it {is_expected.to validate_presence_of(:city)}
  it {is_expected.to validate_presence_of(:state_code)}

  it {is_expected.to validate_presence_of(:slug)}
  
  it {expect(create(:nonprofit)).to validate_uniqueness_of(:slug).scoped_to(:city_slug, :state_code_slug)}

  it{ is_expected.to have_one(:billing_plan).through(:billing_subscription)}

  it {is_expected.to have_many(:supporter_cards).class_name('Card').through(:supporters).source(:cards)}

  describe 'with cards' do
    before(:each) do
      @nonprofit = create(:nonprofit_with_cards)

    end
    before (:each) do
      cards = @nonprofit.cards.to_ary
      @card1 = cards.first{|i| i.name == 'card1'}
      @card2 = cards.first{|i| i.name == 'card2'}
      @card3 = cards.first{|i| i.name == 'card3'}
    end
    describe '.active_cards' do
      it 'should return all cards' do
        cards = @nonprofit.active_cards
        expect(cards.length).to eq(2)
      end
    end
    describe '.active_card' do
      it 'should return one' do
        card = @nonprofit.active_card
        expect(card).to_not be_nil
      end
    end
    describe '.create_active_card' do
      it 'should become active and turn others inactive' do
        previously_active_cards = @nonprofit.active_cards
        card = @nonprofit.create_active_card(name: 'card 4')
        expect(card).to_not be_nil
        expect(card.name).to eq(@nonprofit.active_card.name)
        expect(!card.inactive)
      end
    end
  end

  describe '.currency_symbol' do

    let(:nonprofit) {force_create(:nonprofit, currency: 'eur')}
    let(:euro){"€"}

    it 'finds correct currency symbol for nonprofit' do
      expect(nonprofit.currency_symbol).to eq euro
    end
  end

  describe '.can_make_payouts?' do 
    let(:np) {force_create(:nonprofit, stripe_account_id: '1')}
    let(:np_vetted) {force_create(:nonprofit, vetted:true,  stripe_account_id: '1')}
    let(:bank_account) {force_create(:bank_account, nonprofit: np_vetted)}
    let(:bank_account_deleted) {force_create(:bank_account, deleted: true)}
    let(:bank_account_pending) {force_create(:bank_account, pending_verification:true)}

    let(:stripe_account) { force_create(:stripe_account, stripe_account_id: '1')}
    let(:stripe_account_payouts_enabled) { force_create(:stripe_account, stripe_account_id: '1', payouts_enabled: true)}

    let(:nonprofit_deactivation) {force_create(:nonprofit_deactivation, nonprofit: np_vetted)}
    let(:nonprofit_deactivation_deactivated) {force_create(:nonprofit_deactivation, deactivated: true, nonprofit: np_vetted)}


    it 'is false on unvetted' do
      np
      expect(np.can_make_payouts?).to be false
    end

    it 'is false on no bank account' do
      np_vetted
      expect(np_vetted.can_make_payouts?).to be false
    end

    it 'is false on deleted bank account' do
      np_vetted
      bank_account_deleted
      expect(np_vetted.can_make_payouts?).to be false
    end

    it 'is false on pending bank account' do
      np_vetted
      bank_account_pending
      expect(np_vetted.can_make_payouts?).to be false
    end

    it 'is false on no stripe_account' do
      np_vetted
      bank_account
      expect(np_vetted.can_make_payouts?).to be false
    end

    it 'is false on stripe_account without payouts_enabled' do
      np_vetted
      bank_account
      stripe_account
      expect(np_vetted.can_make_payouts?).to be false
    end

    it 'is false on deactivated nonprofit' do
      np_vetted
      bank_account
      stripe_account_payouts_enabled
      nonprofit_deactivation_deactivated
      expect(np_vetted.can_make_payouts?).to be false
    end

    it 'is true when no nonprofit_deactivaton record exists' do
      np_vetted
      bank_account
      stripe_account_payouts_enabled
      expect(np_vetted.can_make_payouts?).to be true
    end

    it 'is true when nonprofit_deactivaton record exists but not deactivated' do
      np_vetted
      bank_account
      stripe_account_payouts_enabled
      nonprofit_deactivation
      expect(np_vetted.can_make_payouts?).to be true
    end
  end

  describe '.timezone_is_valid' do
    it 'does not fail if the timezone is nil' do
      expect { create(:nonprofit, timezone: nil) }.not_to raise_error
    end

    it 'does not fail if the timezone is readable by postgres' do
      expect { create(:nonprofit, timezone: 'America/Chicago') }.not_to raise_error
    end

    it 'raises error if the timezone is invalid' do
      expect { create(:nonprofit, timezone: 'Central Time (US & Canada)') }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe '::FeeCalculation' do
    include_context 'common fee scenarios'
    subject(:nonprofit){ create(:nonprofit_with_billing_plan_percentage_fee_of_2_5_percent_and_5_cents_flat)}

    SCENARIOS.each do |example|

      describe '#calculate_fee' do 
        context "when charge is #{example[:at]}" do 
          context "for #{example[:source]}" do
          it {
            expect(nonprofit.calculate_fee(amount:example[:amount], source: get_source(example), at: at(example))).to eq example[:calculate_fee_result]
          }
          end
        end
      end

      describe '#calculate_stripe_fee' do
        
        let(:calculate_stripe_fee_result) { 
          example[:calculate_stripe_fee_result]
        }
        context "when charge is #{example[:at]}" do 
          context "for #{example[:source]}" do
          

            it {
              expect(nonprofit.calculate_stripe_fee(amount:example[:amount], source: get_source(example), at: at(example))).to eq calculate_stripe_fee_result
            }
          end
        end
      end

      describe '#calculate_application_fee_refund' do
        
        context "when charge is #{example[:at]}" do
          context "for #{example[:source]}" do
            example[:refunds].each do |refund|
              context "with following inputs #{refund}" do
              
                let(:stripe_charge) { 
                  Stripe::Charge.construct_from({id: 'charge_id_1', amount: example[:amount], source: get_source(example), application_fee: 'app_fee_1', created: (Time.current).to_i, refunded: refund[:charge_marked_as_refunded]})
        
                }

                let(:stripe_refund) { 
                  Stripe::Refund.construct_from({charge: stripe_charge.id, amount: refund[:amount_refunded]})
                }

                let(:stripe_application_fee) {
                  Stripe::ApplicationFee.construct_from({amount_refunded: refund[:application_fee_refunded_already], id: 'app_fee_1', amount: example[:calculate_fee_result]})
                }
              
                
                it {
                  expect(nonprofit.calculate_application_fee_refund(charge_date: at(example), charge: stripe_charge, refund: stripe_refund, application_fee: stripe_application_fee)).to eq refund[:calculate_application_fee_refund_result]
                }
              end
            end
          end
        end
      end
    end

    describe '#fee_coverage_details' do
      context 'for a nonprofit with CC percentage_fee 2.5% + 5 cents' do
        let(:nonprofit){ create(:nonprofit_with_billing_plan_percentage_fee_of_2_5_percent_and_5_cents_flat)}
        it {
          expect(nonprofit.fee_coverage_details).to eq({percentage_fee: BigDecimal.new("0.025") + BigDecimal.new("0.022"), flat_fee: 35})
        }
      end
      context 'for a nonprofit with CC percentage_fee 2.5% + 5 cents but in a fee era where we dont consider billing plan' do 
        let(:nonprofit){  create(:nonprofit_with_billing_plan_percentage_fee_of_2_5_percent_and_5_cents_flat)}
        before(:each) do 
          FeeEra.current.fee_coverage_detail_base = build(:dont_consider_billing_plan_fee_coverage_detail_base)
          FeeEra.current.fee_coverage_detail_base.save!
        end

        it {
          expect(nonprofit.fee_coverage_details).to eq({percentage_fee: BigDecimal.new("0.05"), flat_fee: 0})
        }
      end
      
    end

    describe '#fee_coverage_details_with_json_safe_keys' do
      context 'for a nonprofit with CC percentage_fee 2.5% + 5 cents' do
        let(:nonprofit){ create(:nonprofit_with_billing_plan_percentage_fee_of_2_5_percent_and_5_cents_flat)}
        it {
          expect(nonprofit.fee_coverage_details_with_json_safe_keys).to eq({'percentageFee' => BigDecimal.new("0.025") + BigDecimal.new("0.022"), 'flatFee' => 35})
        }
      end

      context 'for a nonprofit with CC percentage_fee 2.5% + 5 cents but in a fee era where we dont consider billing plan' do 
        let(:nonprofit){  create(:nonprofit_with_billing_plan_percentage_fee_of_2_5_percent_and_5_cents_flat)}
        before(:each) do 
          FeeEra.current.fee_coverage_detail_base = build(:dont_consider_billing_plan_fee_coverage_detail_base)
          FeeEra.current.fee_coverage_detail_base.save!
        end

        it {
          expect(nonprofit.fee_coverage_details_with_json_safe_keys).to eq({'percentageFee' => BigDecimal.new("0.05"), 'flatFee' => 0})
        }
      end
    end
  end
end
