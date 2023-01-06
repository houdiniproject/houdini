# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'

RSpec.describe Nonprofit, type: :model do
  it_behaves_like 'an houidable entity', :np

  it {is_expected.to validate_presence_of(:name)}
  
  it {is_expected.to validate_presence_of(:city)}
  it {is_expected.to validate_presence_of(:state_code)}

  it {is_expected.to validate_presence_of(:slug)}
  
  it {expect(create(:nonprofit)).to validate_uniqueness_of(:slug).scoped_to(:city_slug, :state_code_slug)}

  it{ is_expected.to have_one(:billing_plan).through(:billing_subscription)}

  it {is_expected.to have_many(:supporter_cards).class_name('Card').through(:supporters).source(:cards)}

  it {is_expected.to have_many(:email_lists)}
  it {is_expected.to have_one(:nonprofit_key)}

  it {is_expected.to have_many(:associated_object_events).class_name("ObjectEvent")}

  describe 'with cards' do
    around(:each) do |ex|
      StripeMockHelper.start
      ex.run
      StripeMockHelper.stop
    end
    
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
          expect(nonprofit.fee_coverage_details).to eq({percentage_fee: BigDecimal("0.025") + BigDecimal("0.022"), flat_fee: 35})
        }
      end
      context 'for a nonprofit with CC percentage_fee 2.5% + 5 cents but in a fee era where we dont consider billing plan' do 
        let(:nonprofit){  create(:nonprofit_with_billing_plan_percentage_fee_of_2_5_percent_and_5_cents_flat)}
        before(:each) do 
          FeeEra.current.fee_coverage_detail_base = build(:dont_consider_billing_plan_fee_coverage_detail_base)
          FeeEra.current.fee_coverage_detail_base.save!
        end

        it {
          expect(nonprofit.fee_coverage_details).to eq({percentage_fee: BigDecimal("0.05"), flat_fee: 0})
        }
      end
      
    end

    describe '#fee_coverage_details_with_json_safe_keys' do
      context 'for a nonprofit with CC percentage_fee 2.5% + 5 cents' do
        let(:nonprofit){ create(:nonprofit_with_billing_plan_percentage_fee_of_2_5_percent_and_5_cents_flat)}
        it {
          expect(nonprofit.fee_coverage_details_with_json_safe_keys).to eq({'percentageFee' => BigDecimal("0.025") + BigDecimal("0.022"), 'flatFee' => 35})
        }
      end

      context 'for a nonprofit with CC percentage_fee 2.5% + 5 cents but in a fee era where we dont consider billing plan' do 
        let(:nonprofit){  create(:nonprofit_with_billing_plan_percentage_fee_of_2_5_percent_and_5_cents_flat)}
        before(:each) do 
          FeeEra.current.fee_coverage_detail_base = build(:dont_consider_billing_plan_fee_coverage_detail_base)
          FeeEra.current.fee_coverage_detail_base.save!
        end

        it {
          expect(nonprofit.fee_coverage_details_with_json_safe_keys).to eq({'percentageFee' => BigDecimal("0.05"), 'flatFee' => 0})
        }
      end
    end
  end

  describe '::Deactivation' do
    let(:nonprofit_without_deactivation_record) { create(:nonprofit)}

    let(:nonprofit_with_deactivated_deactivation_record) { 
     create(:nonprofit_with_deactivated_deactivation_record)
    }

    let(:nonprofit_with_activated_deactivation_record) { 
      create(:nonprofit_with_activated_deactivation_record)
    }

    describe '.activated' do
      it {
        nonprofit_without_deactivation_record
        expect(Nonprofit.activated).to include nonprofit_without_deactivation_record
      }

      it {
        nonprofit_with_activated_deactivation_record
        expect(Nonprofit.activated).to include nonprofit_with_activated_deactivation_record
      }

      it {
        nonprofit_with_deactivated_deactivation_record
        expect(Nonprofit.activated).to_not include nonprofit_with_deactivated_deactivation_record
      }
    end

    describe '.deactivated' do
      it {
        nonprofit_without_deactivation_record
        expect(Nonprofit.deactivated).to_not include nonprofit_without_deactivation_record
      }

      it {
        nonprofit_with_activated_deactivation_record
        expect(Nonprofit.deactivated).to_not include nonprofit_with_activated_deactivation_record
      }

      it {
        nonprofit_with_deactivated_deactivation_record
        expect(Nonprofit.deactivated).to include nonprofit_with_deactivated_deactivation_record
      }
    end

    describe '#activated?' do
     
      it {
        expect(nonprofit_without_deactivation_record.activated?).to eq true
      }

      it {
        expect(nonprofit_with_deactivated_deactivation_record.activated?).to eq false
      }

      it {
        expect(nonprofit_with_activated_deactivation_record.activated?).to eq true
      }
    end

    describe '#deactivated?' do
      it {
        expect(nonprofit_without_deactivation_record.deactivated?).to eq false
      }

      it {
        expect(nonprofit_with_deactivated_deactivation_record.deactivated?).to eq true
      }

      it {
        expect(nonprofit_with_activated_deactivation_record.deactivated?).to eq false
      }
    end

    describe '#deactivate!' do
      it {
        nonprofit_without_deactivation_record.deactivate!
        expect(nonprofit_without_deactivation_record.published).to eq false
        expect(nonprofit_without_deactivation_record.deactivated?).to eq true
      }

      it {
        nonprofit_with_deactivated_deactivation_record.deactivate!
        expect(nonprofit_with_deactivated_deactivation_record.published).to eq false
        expect(nonprofit_with_deactivated_deactivation_record.deactivated?).to eq true
      }

      it {
        nonprofit_with_activated_deactivation_record.deactivate!
        expect(nonprofit_with_activated_deactivation_record.published).to eq false
        expect(nonprofit_with_activated_deactivation_record.deactivated?).to eq true
      }
    end
  end

  describe '::S3Keys' do
    it {is_expected.to have_many(:nonprofit_s3_keys)}
  end

  describe '::DateAndTime' do
    
    describe '#zone' do
      it 'returns UTC if the nonprofit has no timezone' do
         expect(build(:nonprofit).zone).to eq ActiveSupport::TimeZone['UTC']
      end
      
      it 'returns UTC if the nonprofit has a blank timezone' do
        expect(build(:nonprofit, timezone: '').zone).to eq ActiveSupport::TimeZone['UTC']
      end

      it 'returns UTC if the nonprofit has an invalid timezone' do
        expect(build(:nonprofit, timezone: 'invalid time').zone).to eq ActiveSupport::TimeZone['UTC']
      end

      it 'returns non-UTC timezone if the nonprofit has an valid timezone' do
        expect(build(:nonprofit, timezone: 'Central Time (US & Canada)').zone).to eq ActiveSupport::TimeZone['Central Time (US & Canada)']
      end
    end
  end

  describe '::Profile' do
    describe '#has_achievements?' do
      it 'is true when there are achievements' do
        nonprofit = build(:nonprofit, achievements: ['Achieve'])
        expect(nonprofit).to be_has_achievements
      end
      
      it 'is false when achievements is empty array' do
        nonprofit = build(:nonprofit, achievements:[])

        expect(nonprofit).to_not be_has_achievements
      end

      it 'is false when achievements is nil' do
        nonprofit = build(:nonprofit, achievements:nil)

        expect(nonprofit).to_not be_has_achievements
      end

      it 'is false when achievements is not an array' do
        nonprofit = build(:nonprofit, achievements:{})

        expect(nonprofit).to_not be_has_achievements
      end
    end
  end

  describe 'Caching' do

    describe 'after save' do
      it 'runs clear_cache after create' do
        np = build(:nonprofit)
        expect(np).to receive(:clear_cache).at_least(:once)

        np.save!
      end

      it 'runs clear_cache after update' do
        np = create(:nonprofit)
        expect(np).to receive(:clear_cache)

        np.email = "someemail@somethingelse.com"
        np.save!
      end
    end

    describe '#clear_cache' do
      it 'calls the .clear_caching class method' do 
        np = create(:nonprofit)
        expect(Nonprofit).to receive(:clear_caching).with(np.id, np.state_code_slug, np.city_slug, np.slug)
        np.clear_cache
      end
    end

    describe '.clear_caching' do
      it 'clears the proper cache keys' do
        id = 1
        state_code = 'wi'
        city = 'appleton'
        name = 'another-org'
        expect(Rails.cache).to receive(:delete).with("nonprofit__CACHE_KEY__ID___#{id}")
        expect(Rails.cache).to receive(:delete).with("nonprofit__CACHE_KEY__LOCATION___#{state_code}____#{city}___#{name}")

        expect(BillingSubscription).to receive(:clear_cache).with(id)
        expect(BillingPlan).to receive(:clear_cache).with(id)
        Nonprofit.clear_caching(id, state_code, city, name)
      end
    end

    describe '.create_cache_key_for_id' do
      it 'creates an accurate cache key' do 
        expect(described_class.create_cache_key_for_id(1234))
          .to eq('nonprofit__CACHE_KEY__ID___1234')
      end
    end

    describe '.create_cache_key_for_location' do
      it 'creates an accurate cache key' do 
        expect(described_class.create_cache_key_for_location('wi', 'appleton', 'another-org'))
          .to eq('nonprofit__CACHE_KEY__LOCATION___wi____appleton___another-org')
      end
    end

    describe '.find_via_cached_id' do
      it 'finds the correct nonprofit' do
        np = create(:nonprofit)
        expect(Rails.cache).to receive(:fetch).with("nonprofit__CACHE_KEY__ID___#{np.id}", expires_in: 4.hours).and_yield

        expect(Nonprofit.find_via_cached_id(np.id)).to eq np
      end

      it 'raises ActiveRecord::RecordNotFound when no valid nonprofit exists' do
        expect(Rails.cache).to receive(:fetch).with("nonprofit__CACHE_KEY__ID___5555", expires_in: 4.hours).and_yield
        expect{ Nonprofit.find_via_cached_id(5555)}.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    describe '.find_via_cached_key_for_location' do
      it 'finds the correct nonprofit' do
        np = create(:nonprofit)
        expect(Rails.cache).to receive(:fetch).with("nonprofit__CACHE_KEY__LOCATION___#{np.state_code_slug}____#{np.city_slug}___#{np.slug}", expires_in: 4.hours).and_yield

        expect(Nonprofit.find_via_cached_key_for_location(np.state_code_slug, np.city_slug, np.slug)).to eq np
      end

      it 'returns nil when no valid nonprofit exists' do
        state_code_slug = "wi"
        city_slug = "green-bay"
        slug = "one-more-org"
        expect(Rails.cache).to receive(:fetch).with("nonprofit__CACHE_KEY__LOCATION___#{state_code_slug}____#{city_slug}___#{slug}", expires_in: 4.hours).and_yield
        expect(Nonprofit.find_via_cached_key_for_location(state_code_slug, city_slug, slug)).to be_nil
      end
    end
  end
end
