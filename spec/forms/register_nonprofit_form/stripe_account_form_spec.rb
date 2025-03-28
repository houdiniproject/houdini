# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

RSpec.describe RegisterNonprofitForm::StripeAccountForm, :type => :model do

  around(:each) do |ex|
    StripeMockHelper.mock do
      ex.run
    end
  end

  context 'validation' do
    it 'accepts a nonprofit' do
      form = described_class.new(nonprofit: build(:nonprofit))
      expect(form).to be_valid
    end

    it 'rejects a string' do
      form = described_class.new(nonprofit: nil)
      expect(form).to_not be_valid
    end

    it 'rejects a string' do
      form = described_class.new(nonprofit: "a string")
      expect(form).to_not be_valid
    end
  end


  describe "#save" do 
    it "sets error when nonprofit is not persisted" do
      form = described_class.new(nonprofit: build(:nonprofit))
      expect(form.save).to be false

      expect(form.errors).to_not be_empty
    end

    it 'sets error when StripeAccountUtils.create returns a nil' do
      

      form = described_class.new(nonprofit: create(:nonprofit))
      expect(StripeAccountUtils).to receive(:create).and_return nil
      expect(form.save).to be false

      expect(form.errors).to_not be_empty
    end


    it 'sets when StripeAccountUtils.create returns an id' do
      nonprofit = create(:nonprofit)
      form = described_class.new(nonprofit: nonprofit)
      
      expect(form.save).to be true

      expect(form.errors).to be_empty

      expect(nonprofit).to be_persisted

      expect(nonprofit.stripe_account_id).to be_present
    end
  end
end
