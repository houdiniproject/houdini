require "rails_helper"

RSpec.describe TicketMailer, type: :mailer do
  describe "followup" do
    let(:ticket) { create(:ticket_base) }

    let(:event) { ticket.event }
    let(:mail) { TicketMailer.followup(ticket.id) }

    context "when its an in_person event" do
      it "renders the google maps link when its an in_person event" do
        expect(mail.body.encoded).to match("maps.google.com")
        expect(mail.body.encoded).to_not match("Virtual")
      end
    end

    context "when its a virtual event" do
      before do
        event.in_person_or_virtual = "virtual"
        event.save!
      end

      it "is listed as virtual without an address" do
        expect(mail.body.encoded).to_not match("maps.google.com")
        expect(mail.body.encoded).to match("Virtual")
      end
    end
  end
end
