require 'rails_helper'
require 'stripe'
require 'stripe_mock'

describe StripeAccount do
  let(:stripe_helper) { StripeMock.create_test_helper }
  before(:each) { StripeMock.start}
  after(:each) { StripeMock.stop}
  let!(:nonprofit) { force_create(:nonprofit)}

  describe '.find_or_create' do
    describe 'param validation' do
      it 'basic param validation' do
        expect { StripeAccount.find_or_create(nil)}.to(raise_error{|error|
          expect(error).to be_a ParamValidation::ValidationError
          expect_validation_errors(error.data, [{:key => :nonprofit_id, :name => :required},
                                                {:key => :nonprofit_id, :name => :is_integer}])
        })
      end

      it 'validate np' do
        expect { StripeAccount.find_or_create(5555)}.to(raise_error{|error|
          expect(error).to be_a ParamValidation::ValidationError
          expect_validation_errors(error.data, [{:key => :nonprofit_id}])
        })
      end
    end
    # basically the same as running create
    describe 'creates new Stripe Account if none is set exists' do
      let!(:result) {StripeAccount.find_or_create(nonprofit.id)}

      it 'returns a Stripe acct id' do
        expect(result).to_not be_blank
      end
      it 'sets the Account values on Stripe' do
        saved_account = Stripe::Account.retrieve(result)
        expect(saved_account['managed']).to eq true
        expect(saved_account['business_name']).to eq (nonprofit.name)
        expect(saved_account['email']).to eq (nonprofit.email)
        expect(saved_account['business_url']).to eq (nonprofit.website)
        expect(saved_account['legal_entity']['type']).to eq ("company")
        expect(saved_account['legal_entity']['address']['city']).to eq (nonprofit.city)
        expect(saved_account['legal_entity']['address']['state']).to eq (nonprofit.state_code)
        expect(saved_account['legal_entity']['business_name']).to eq (nonprofit.name)
        expect(saved_account['product_description']).to eq ('Nonprofit donations')
        expect(saved_account['transfer_schedule']['interval']).to eq('manual')
      end

      it 'updates the nonprofit itself' do
        np = Nonprofit.find(nonprofit.id)
        expect(np.stripe_account_id).to eq result
      end
    end

    describe 'get stripe account from database' do
      let(:stripe_acct_id) { 'stripe_account_id'}

      let!(:result) {
        nonprofit.stripe_account_id = stripe_acct_id
        nonprofit.slug = "slug"
        nonprofit.save!
        nonprofit.reload
        StripeAccount.find_or_create(nonprofit.id)
      }

      it 'returns the expected id' do
        expect(result).to eq stripe_acct_id
      end
    end
  end



  describe '.create' do
    it 'param validation' do
      expect { StripeAccount.create(nil)}.to(raise_error{|error|
        expect(error).to be_a ParamValidation::ValidationError
        expect_validation_errors(error.data, [{:key => :np, :name => :required},
                                                                  {:key => :np, :name => :is_a}])
      })
    end
  end

  describe 'testing with valid nonprofit' do
    it 'handles Stripe errors properly' do
      StripeMock.prepare_error(Stripe::StripeError.new, :new_account)
      expect { StripeAccount.create(nonprofit)}.to(raise_error{|error|
        expect(error).to be_a Stripe::StripeError
        expect(nonprofit.stripe_account_id).to be_blank

      })
    end

    describe 'saves properly' do

      let!(:result) { StripeAccount.create(nonprofit)}

      it 'returns a Stripe acct id' do
        expect(result).to_not be_blank
      end
      it 'sets the Account values on Stripe' do
        saved_account = Stripe::Account.retrieve(result)
        expect(saved_account['managed']).to eq true
        expect(saved_account['business_name']).to eq (nonprofit.name)
        expect(saved_account['email']).to eq (nonprofit.email)
        expect(saved_account['business_url']).to eq (nonprofit.website)
        expect(saved_account['legal_entity']['type']).to eq ("company")
        expect(saved_account['legal_entity']['address']['city']).to eq (nonprofit.city)
        expect(saved_account['legal_entity']['address']['state']).to eq (nonprofit.state_code)
        expect(saved_account['legal_entity']['business_name']).to eq (nonprofit.name)
        expect(saved_account['product_description']).to eq ('Nonprofit donations')
        expect(saved_account['transfer_schedule']['interval']).to eq('manual')
      end

      it 'updates the nonprofit itself' do
        np = Nonprofit.find(nonprofit.id)
        expect(np.stripe_account_id).to eq result
      end
    end
  end

end
