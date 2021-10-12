# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'

describe PeriodicReportAdapter::FailedRecurringDonationsReport do
  let(:nonprofit) { create(:fv_poverty) }
  let(:user) { create(:user) }
  let(:options) do
    {
      :nonprofit_id => nonprofit.id,
      :period => :last_month,
      :user_id => user.id
    }
  end

  let(:params) do
    {
      :failed => true,
      :include_last_failed_charge => true,
      :started_at => Time.new(2021, 9, 1),
      :end_date => Time.new(2021, 10, 1)
    }
  end

  let(:export_recurring_donations) { double }

  subject { described_class.new(options).run }

  around(:each) do |e|
    Timecop.freeze(2021, 10, 21) do
      e.run
    end
  end

  before do
    allow(ExportRecurringDonations)
      .to receive(:initiate_export)
      .with(nonprofit.id, params, user.id, false)
      .and_return(export_recurring_donations)
  end

  it 'calls ExportRecurringDonations::initiate_export with the correct arguments' do
    subject
    expect(ExportRecurringDonations)
      .to have_received(:initiate_export)
      .with(nonprofit.id, params, user.id, false)
  end
end
