# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

RSpec.describe ExportFormat, type: :model do
  let(:nonprofit) { force_create(:fv_poverty) }

  describe "#validation" do
    let(:attributes) do
      {
        "name" => "CiviCRM format",
        "date_format" => "MM/DD/YYYY",
        "show_currency" => false,
        "custom_columns_and_values" => {
          "payments.kind" => {
            "custom_values" => {
              "RecurringDonation" => "Recurring Donation"
            }
          },
          "payments.date" => {
            "custom_name" => "Payment Date"
          }
        }
      }
    end

    subject { nonprofit.export_formats.create(attributes) }

    it "is valid" do
      expect(subject.valid?).to be_truthy
    end

    context "when it does not include a name" do
      before do
        attributes.delete("name")
      end

      it "is invalid" do
        expect(subject.valid?).to be_falsy
      end
    end

    context "when custom_columns_and_values does not follow expected format" do
      context "when it tries to customize a column that is not allowed" do
        before do
          attributes["custom_columns_and_values"]["donations.dedication"] = {
            "custom_name" => "Dedicated to"
          }
        end

        it "is invalid" do
          expect(subject.valid?).to be_falsy
        end
      end

      context "when it tries to customize a value from a column that is not supported" do
        before do
          attributes["custom_columns_and_values"]["offsite_payments.check_number"] = {
            "custom_values" => {
              "1234" => "12345"
            }
          }
        end

        it "is invalid" do
          expect(subject.valid?).to be_falsy
        end
      end

      context "when a customization does not specify a custom_value or custom_name" do
        before do
          attributes["custom_columns_and_values"]["payments.kind"] = {
            "kind" => "Type"
          }
        end

        it "is invalid" do
          expect(subject.valid?).to be_falsy
        end
      end
    end

    context "when date_format is not provided" do
      let(:attributes) do
        {
          "name" => "CiviCRM format",
          "show_currency" => false
        }
      end

      it "is valid" do
        expect(subject.valid?).to be_truthy
      end
    end

    context "when date_format contains invalid separator" do
      let(:attributes) do
        {
          "name" => "CiviCRM format",
          "date_format" => "HH'mm"
        }
      end

      it "is invalid" do
        expect(subject.valid?).to be_falsy
      end
    end

    context "when date_format contains invalid pattern" do
      let(:attributes) do
        {
          "name" => "CiviCRM format",
          "date_format" => "HH:mm seconds"
        }
      end

      it "is invalid" do
        expect(subject.valid?).to be_falsy
      end
    end
  end

  describe "#after_validation" do
    let(:attributes) do
      {
        "name" => "CiviCRM format",
        "date_format" => "MM/DD/YYYY",
        "show_currency" => false,
        "custom_columns_and_values" => {
          "payments.kind" => {
            "custom_values" => {
              "RecurringDonation" => "Recurring Donation"
            }
          },
          "payments.date" => {
            "custom_name" => "Payment Date"
          }
        }
      }
    end

    subject { nonprofit.export_formats.create(attributes) }

    it "adds double quote to custom_name" do
      expect(subject.custom_columns_and_values["payments.date"]["custom_name"])
        .to eq('"Payment Date"')
    end
  end
end
