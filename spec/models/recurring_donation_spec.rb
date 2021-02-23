# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'

RSpec.describe RecurringDonation, type: :model do
  describe '.will_attempt_again?' do 
    let(:cancelled) { force_create(:recurring_donation, active:false, n_failures: 0)}

    let(:failed) { force_create(:recurring_donation, active:true, n_failures: 3)}

    let(:normal) { force_create(:recurring_donation, active:true, n_failures: 2)}

    it 'wont if cancelled' do
      expect(cancelled).to_not be_will_attempt_again
    end

    it 'wont if failed' do
      expect(failed).to_not be_will_attempt_again
    end

    it 'will if not failed or cancelled' do 
      expect(normal).to be_will_attempt_again
    end
  end
end
