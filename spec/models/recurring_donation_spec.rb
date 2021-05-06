# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'

RSpec.describe RecurringDonation, type: :model do
  let!(:cancelled) { force_create(:recurring_donation, active:false, n_failures: 0)}

  let!(:failed) { force_create(:recurring_donation, active:true, n_failures: 3)}

  let!(:normal) { force_create(:recurring_donation, active:true, n_failures: 2)}

  let!(:ended) { force_create(:recurring_donation, active:true, n_failures: 2, end_date: Time.current - 1.day)}

  let!(:ends_in_future) {  force_create(:recurring_donation, active:true, n_failures: 0,  end_date: Time.current + 1.day)}
  describe '.will_attempt_again?' do 

    it 'wont if cancelled' do
      expect(cancelled).to_not be_will_attempt_again
    end

    it 'wont if failed' do
      expect(failed).to_not be_will_attempt_again
    end

    it 'will if not failed or cancelled' do 
      expect(normal).to be_will_attempt_again
    end

    it 'wont if ended' do 
      expect(ended).to_not be_will_attempt_again
    end

    it 'will if ends in future' do 
      expect(ends_in_future).to be_will_attempt_again
    end
  end

  describe '.may_attempt_again scope' do
    subject { RecurringDonation.may_attempt_again}

    it { is_expected.to include normal}

    it { is_expected.to_not include cancelled}

    it { is_expected.to_not include failed}

    it { is_expected.to_not include ended}

    it {is_expected.to include ends_in_future}
  end
end
