# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'

describe StripeMockHelper do  
  it 'sets stripe_helper' do
    expect(StripeMockHelper.stripe_helper).to be_falsy
    StripeMockHelper.mock do
      expect(StripeMockHelper.stripe_helper).to be_truthy
    end
  end

  it 'clears stripe_helper when finished' do
    StripeMockHelper.mock do
    end
    expect(StripeMockHelper.stripe_helper).to be_falsy
  end

  describe "#start" do
    it 'is safely reentrant' do
      StripeMockHelper.mock do
        # products are now required in plans as of Stripe gem 5.0
        product = StripeMockHelper.stripe_helper.create_product
        # create a plan
        StripeMockHelper.stripe_helper.create_plan(id: 'test_str_plan', amount:0, currency: 'usd', interval: 'year', name: 'test PLan', product: product.id)
        StripeMockHelper.start
        expect { Stripe::Plan.retrieve('test_str_plan')}.to_not(raise_error, "If this object is not available, \
          then the StripeMockHelper.start is incorrectly creating a new StripeMock session")
      end
    end
  end
end