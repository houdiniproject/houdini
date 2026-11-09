# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

describe QueryEventMetrics do
  let(:nonprofit) { create(:nonprofit_base) }
  let(:supporter) { create(:supporter_base, nonprofit:) }
  let(:supporter2) { create(:supporter_base, nonprofit:) }

  let!(:event_active1) do
    create(:event_base, nonprofit:, published: true, organizer_email: "organizer1@example.com",
      start_datetime: 10.days.ago.at_beginning_of_day, end_datetime: 10.days.since.at_beginning_of_day)
  end

  let!(:event_active2) do
    create(:event_base, nonprofit:, published: true, organizer_email: "organizer2@example.com", in_person_or_virtual: "virtual",
      start_datetime: 10.days.ago.at_beginning_of_day, end_datetime: 20.days.since.at_beginning_of_day)
  end

  let!(:ticket_level) { create(:ticket_level, event: event_active2, name: "General admission") }

  # Two tickets, two payments (21.37 + 10.85 = $32.22)
  let!(:ticket_payment1) { create(:payment, supporter:, nonprofit:, gross_amount: 2137, fee_total: -159, net_amount: 1978) }
  let!(:ticket1) { create(:ticket, event: event_active2, supporter:, payment: ticket_payment1, ticket_level:, checked_in: true, quantity: 4) }
  let!(:ticket_payment2) { create(:payment, supporter:, nonprofit:, gross_amount: 1085, fee_total: -85, net_amount: 1000) }
  let!(:ticket2) { create(:ticket, event: event_active2, supporter: supporter2, payment: ticket_payment2, ticket_level:, checked_in: nil, quantity: 3) }

  # Two donations (26.64 + 52.95 = $79.59)
  let!(:donation_payment1) { create(:payment, supporter:, nonprofit:, gross_amount: 2664, fee_total: -164, net_amount: 2500) }
  let!(:donation1) { create(:donation_base, supporter:, nonprofit:, event: event_active2, amount: 2664, payment: donation_payment1) }
  let!(:donation_payment2) { create(:payment, supporter:, nonprofit:, gross_amount: 5295, fee_total: -295, net_amount: 5000) }
  let!(:donation2) { create(:donation_base, supporter:, nonprofit:, event: event_active2, amount: 5295, payment: donation_payment2) }

  let!(:event_past) { create(:event_base, nonprofit:, published: true, start_datetime: 21.days.ago, end_datetime: 20.days.ago.at_beginning_of_day) }
  let!(:event_deleted) { create(:event_base, nonprofit:, deleted: true) }
  let!(:event_unpublished) { create(:event_base, nonprofit:) }

  let!(:other_nonprofit) { create(:nonprofit_base) }
  let!(:other_event_active1) { create(:event_base, nonprofit: other_nonprofit, published: true, end_datetime: 10.days.since) }
  let!(:other_event_active2) { create(:event_base, nonprofit: other_nonprofit, published: true, end_datetime: 20.days.since) }

  describe ".for_listings" do
    describe "for nonprofit" do
      describe "active" do
        subject(:results) { QueryEventMetrics.for_listings("nonprofit", nonprofit.id, {"active" => true}) }

        it "query result has correct attributes" do
          # the query doesn't order its results, so look events up by id
          expect(results.map { |r| r["id"] }).to contain_exactly(event_active1.id, event_active2.id)

          result = results.find { |r| r["id"] == event_active2.id }
          expect(result["name"]).to eq event_active2.name
          expect(result["venue_name"]).to eq event_active2.venue_name
          expect(result["address"]).to eq event_active2.address
          expect(result["city"]).to eq event_active2.city
          expect(result["state_code"]).to eq event_active2.state_code
          expect(result["zip_code"]).to eq event_active2.zip_code
          expect(result["start_datetime"]).to eq 10.days.ago.at_beginning_of_day
          expect(result["end_datetime"]).to eq 20.days.since.at_beginning_of_day
          expect(result["organizer_email"]).to eq event_active2.organizer_email
          expect(result["in_person_or_virtual"]).to eq "virtual"
          expect(result["checked_in_count"]).to eq 1
          expect(result["total_attendees"]).to eq 7
          expect(result["tickets_total_paid"]).to eq 3_222
          expect(result["donations_total_paid"]).to eq 7_959
          expect(result["total_paid"]).to eq(3_222 + 7_959)
        end

        it "counts a payment once when it covers tickets at more than one level" do
          # buying two ticket levels in one checkout creates two ticket rows that share one payment
          other_supporter = create(:supporter_base, nonprofit: other_nonprofit)
          general = create(:ticket_level, event: other_event_active1, name: "General admission")
          vip = create(:ticket_level, event: other_event_active1, name: "VIP")
          payment = create(:payment, supporter: other_supporter, nonprofit: other_nonprofit, gross_amount: 5_000, fee_total: 0, net_amount: 5_000)
          create(:ticket, event: other_event_active1, supporter: other_supporter, payment:, ticket_level: general, quantity: 2)
          create(:ticket, event: other_event_active1, supporter: other_supporter, payment:, ticket_level: vip, quantity: 1)

          other_results = QueryEventMetrics.for_listings("nonprofit", other_nonprofit.id, {"active" => true})
          result = other_results.find { |r| r["id"] == other_event_active1.id }
          expect(result["total_attendees"]).to eq 3
          expect(result["tickets_total_paid"]).to eq 5_000
          expect(result["total_paid"]).to eq 5_000
        end
      end

      describe "past" do
        subject(:results) { QueryEventMetrics.for_listings("nonprofit", nonprofit.id, {"past" => true}) }

        it "query result has correct element" do
          expect(results.count).to eq 1
          expect(results.first["id"]).to eq event_past.id
        end
      end

      describe "unpublished" do
        subject(:results) { QueryEventMetrics.for_listings("nonprofit", nonprofit.id, {"unpublished" => true}) }

        it "query result has correct element" do
          expect(results.count).to eq 1
          expect(results.first["id"]).to eq event_unpublished.id
        end
      end

      describe "deleted" do
        subject(:results) { QueryEventMetrics.for_listings("nonprofit", nonprofit.id, {"deleted" => true}) }

        it "query result has correct element" do
          expect(results.count).to eq 1
          expect(results.first["id"]).to eq event_deleted.id
        end
      end
    end

    describe "for profile" do
      skip "TODO"
    end
  end

  describe ".with_event_ids" do
    skip "TODO"
  end
end
