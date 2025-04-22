# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

RSpec.describe PeriodicReport, type: :model do
  let(:nonprofit) { create(:nonprofit_base) }
  let(:user) { create(:user, roles: [build(:role, name: "nonprofit_associate", host: nonprofit)]) }
  let(:users_list) { User.where(id: user.id) }

  it { is_expected.to belong_to(:nonprofit).required(true) }
  it { is_expected.to belong_to(:nonprofit_s3_key) }

  describe "#validation" do
    let(:attributes) do
      {
        active: true,
        report_type: :failed_recurring_donations,
        period: :last_month,
        users: users_list
      }
    end

    subject { nonprofit.periodic_reports.create(attributes) }

    it "is valid if it has the correct attributes" do
      periodic_report = subject
      expect(periodic_report.valid?).to be_truthy
    end

    it "is not valid if it does not have a supported report_type" do
      attributes[:report_type] = :invalid_report_type
      periodic_report = subject
      expect(periodic_report.valid?).to be_falsy
    end

    it "is not valid if it does not have a supported period" do
      attributes[:period] = :invalid_period
      periodic_report = subject
      expect(periodic_report.valid?).to be_falsy
    end

    it "is not valid if it the nonprofit on nonprofit_s3_key does not match nonprofit" do
      attributes[:nonprofit_s3_key] = create(:nonprofit_s3_key)
      periodic_report = subject
      expect(periodic_report.valid?).to be_falsy
    end

    it "is valid if it the nonprofit on nonprofit_s3_key does match nonprofit" do
      attributes[:nonprofit_s3_key] = create(:nonprofit_s3_key, nonprofit: nonprofit)
      periodic_report = subject
      expect(periodic_report.valid?).to be_truthy
    end

    context "users validation" do
      it "is not valid if user does not belong to given nonprofit" do
        attributes[:users] = [create(:user)]
        periodic_report = subject
        expect(periodic_report.valid?).to be_falsy
      end

      it "is not valid if a list of users is not provided" do
        attributes[:users] = []
        periodic_report = subject
        expect(periodic_report.valid?).to be_falsy
      end

      it "is valid if the user provided is a super admin" do
        attributes[:users] = [create(:user, roles: [build(:role, name: "super_admin")])]
        periodic_report = subject
        expect(periodic_report.valid?).to be_truthy
      end
    end
  end

  describe "scopes" do
    describe "#active" do
      let(:attributes) do
        [{
          active: true,
          report_type: :failed_recurring_donations,
          period: :last_month,
          users: users_list
        }, {
          active: true,
          report_type: :failed_recurring_donations,
          period: :last_month,
          users: users_list
        }, {
          active: false,
          report_type: :failed_recurring_donations,
          period: :last_month,
          users: users_list
        }]
      end

      subject { described_class.active }

      before do
        attributes.each do |attr|
          nonprofit.periodic_reports.create(attr)
        end
      end

      it "finds active periodic reports" do
        expect(subject.count).to eq(2)
      end
    end
  end

  describe "#run" do
    it { is_expected.to delegate_method(:run).to(:adapter) }

    context "when the report is for failed recurring donations" do
      let(:attributes) do
        {
          active: true,
          report_type: "failed_recurring_donations",
          period: "last_month",
          users: users_list,
          nonprofit_s3_key: nil,
          filename: nil
        }
      end
      let(:options) { attributes.except(:active).merge({nonprofit_id: nonprofit.id}) }

      let(:failed_recurring_donations_report) { double }

      before do
        allow(PeriodicReportAdapter::FailedRecurringDonationsReport)
          .to receive(:new)
          .with(options)
          .and_return(failed_recurring_donations_report)
      end

      it "calls the correct corresponding adapter" do
        expect(failed_recurring_donations_report).to receive(:run)
        nonprofit.periodic_reports.create(attributes).run
      end
    end

    context "when the report is for cancelled recurring donations" do
      let(:attributes) do
        {
          active: true,
          report_type: "cancelled_recurring_donations",
          period: "last_month",
          users: users_list,
          nonprofit_s3_key: nil,
          filename: nil
        }
      end
      let(:options) { attributes.except(:active).merge({nonprofit_id: nonprofit.id}) }

      let(:cancelled_recurring_donations_report) { double }

      before do
        allow(PeriodicReportAdapter::CancelledRecurringDonationsReport)
          .to receive(:new)
          .with(options)
          .and_return(cancelled_recurring_donations_report)
      end

      it "calls the correct corresponding adapter" do
        expect(cancelled_recurring_donations_report).to receive(:run)
        nonprofit.periodic_reports.create(attributes).run
      end
    end
  end
end
