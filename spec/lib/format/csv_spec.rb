# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"
describe Format::Csv do
  describe ".from_data" do
    def create_output
      [
        {
          email_address: "email@email.com", name: "Eric Schultz"
        },
        {
          email_address: "penelope@email.com", name: "Penelope Schultz"
        }
      ]
    end
    context "no titleize_header passed" do
      it "titleizes the header" do
        result = Format::Csv.from_data(create_output)
        expect(result).to eq "Email Address,Name\nemail@email.com,Eric Schultz\npenelope@email.com,Penelope Schultz\n"
      end
    end

    context "false titleize_header passed" do
      it "titleizes the header" do
        result = Format::Csv.from_data(create_output, titleize_header: false)
        expect(result).to eq "email_address,name\nemail@email.com,Eric Schultz\npenelope@email.com,Penelope Schultz\n"
      end
    end

    context "true titleize_header passed" do
      it "titleizes the header" do
        result = Format::Csv.from_data(create_output, titleize_header: true)
        expect(result).to eq "Email Address,Name\nemail@email.com,Eric Schultz\npenelope@email.com,Penelope Schultz\n"
      end
    end
  end
end
