# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

describe PeriodicReportAdapter do
  let(:nonprofit_id) { create(:fv_poverty).id }
  let(:user) { create(:user) }
  let(:options) { {report_type: :failed_recurring_donations, nonprofit_id: nonprofit_id, period: :last_month, users: [user]} }

  let(:failed_recurring_donations_report) { double }

  subject { described_class.build(options) }

  before do
    allow(PeriodicReportAdapter::FailedRecurringDonationsReport)
      .to receive(:new)
      .with(options)
      .and_return(failed_recurring_donations_report)
  end

  it "returns an instance of FailedRecurringDonationsReport given a failed_recurring_donations report type and its options" do
    expect(subject).to eq(failed_recurring_donations_report)
  end
end
