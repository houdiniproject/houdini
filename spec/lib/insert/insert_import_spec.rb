# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

describe InsertImport do
  describe "parsing" do
    let(:user) { create(:user) }
    subject(:import_result) do
      import = InsertImport.from_csv(
        nonprofit_id: create(:fv_poverty).id,
        user_email: user.email,
        user_id: user.id,
        file_uri: "#{ENV["PWD"]}/spec/fixtures/test_import.csv",
        header_matches: {
          "Date" => "donation.date",
          "Program" => "donation.designation",
          "Amount" => "donation.amount",
          "Business or organization name" => "supporter.organization",
          "First Name" => "supporter.first_name",
          "Last Name" => "supporter.last_name",
          "Address" => "supporter.address",
          "City" => "supporter.city",
          "State" => "supporter.state_code",
          "Zip Code" => "supporter.zip_code",
          "EMAIL" => "supporter.email",
          "notes" => "donation.comment",
          "Field Guy" => "custom_field",
          "Tag 1" => "tag",
          "Tag 2" => "tag"
        }
      )

      Import.find(import["id"])
    end

    it { expect { import_result }.to change { Supporter.count }.by(5) }
    it { expect { import_result }.to change { Payment.count }.by(5) }

    describe "import for user@example1.com" do
      subject(:supporter) {
        import_result
        Supporter.find_by_email("user@example1.com")
      }

      it do
        is_expected.to have_attributes(
          donations:
            a_collection_containing_exactly(
              an_instance_of(Donation).and(have_attributes(amount: 1000))
            )
        )
      end
      it {
        is_expected.to have_attributes(
          address: "P.O. Box 611",
          city: "Snead",
          state_code: "AL",
          zip_code: "35952"
        )
      }

      describe "primary_address" do
        subject {
          supporter.primary_address
        }

        it do
          is_expected.to have_attributes(
            address: "P.O. Box 611",
            city: "Snead",
            state_code: "AL",
            zip_code: "35952"
          )
        end
      end
    end

    describe "import for user2@example2.com" do
      subject(:supporter) {
        import_result
        Supporter.find_by_email("user2@example2.com")
      }

      it do
        is_expected.to have_attributes(
          donations:
            a_collection_containing_exactly(
              an_instance_of(Donation).and(have_attributes(amount: 1040))
            )
        )
      end

      it {
        is_expected.to have_attributes(
          address: "P.O. Box 143",
          city: "Holly Pond",
          state_code: "AL",
          zip_code: "35806"
        )
      }

      describe "primary_address" do
        subject {
          supporter.primary_address
        }

        it do
          is_expected.to have_attributes(
            address: "P.O. Box 143",
            city: "Holly Pond",
            state_code: "AL",
            zip_code: "35806"
          )
        end
      end
    end

    describe "import for user5@example.com" do
      subject(:supporter) {
        import_result
        Supporter.find_by_email("user5@example.com")
      }

      it do
        is_expected.to have_attributes(
          donations:
            a_collection_containing_exactly(
              an_instance_of(Donation).and(have_attributes(amount: 0))
            )
        )
      end
      it {
        is_expected.to have_attributes(
          address: nil,
          city: "Guntersville",
          state_code: "WI",
          zip_code: "54915"
        )
      }

      describe "primary_address" do
        subject {
          supporter.primary_address
        }

        it do
          is_expected.to have_attributes(
            address: nil,
            city: "Guntersville",
            state_code: "WI",
            zip_code: "54915"
          )
        end
      end
    end

    describe "import for Bill Waddell" do
      subject(:supporter) {
        import_result
        Supporter.find_by_name("Bill Waddell")
      }

      it do
        is_expected.to have_attributes(
          donations:
            a_collection_containing_exactly(
              an_instance_of(Donation).and(have_attributes(amount: 1000))
            )
        )
      end
      it do
        is_expected.to have_attributes(
          name: "Bill Waddell",
          email: "user@example.com",
          address: "649 Finley Island Road",
          city: "Decatur",
          state_code: "AL",
          zip_code: "35601"
        )
      end

      describe "primary_address" do
        subject {
          supporter.primary_address
        }

        it "will keep the address from the first supporter" do
          is_expected.to have_attributes(
            address: "649 Finley Island Road",
            city: "Decatur",
            state_code: "AL",
            zip_code: "35601"
          )
        end
      end
    end

    describe "import for Bubba Thurmond" do
      subject(:supporter) {
        import_result
        Supporter.find_by_name("Bubba Thurmond")
      }

      it do
        is_expected.to have_attributes(
          donations:
            a_collection_containing_exactly(
              an_instance_of(Donation).and(have_attributes(amount: 1000))
            )
        )
      end
      it do
        is_expected.to have_attributes(
          name: "Bubba Thurmond",
          email: "user@example.com",
          address: "3370 Alabama Highway 69",
          city: "Guntersville",
          state_code: "AL",
          zip_code: "35976"
        )
      end

      describe "primary_address" do
        subject {
          supporter.primary_address
        }

        it "will keep the address from the first supporter" do
          is_expected.to have_attributes(
            address: "3370 Alabama Highway 69",
            city: "Guntersville",
            state_code: "AL",
            zip_code: "35976"
          )
        end
      end
    end
  end
end
