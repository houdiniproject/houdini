# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"

describe UpdateRecurringDonations do
  # deactivate a recurring donation
  describe ".cancel" do
    let!(:np) { force_create(:nm_justice) }
    let(:s) { force_create(:supporter, nonprofit: np) }
    let(:donation) { force_create(:donation, nonprofit_id: np.id, supporter_id: s.id) }
    let(:email) { "test@test.com" }
    let!(:rd) do
      inner_rd = force_create(:recurring_donation, amount: 999, active: true, supporter_id: s.id, donation_id: donation.id, nonprofit_id: np.id)
      UpdateRecurringDonations.cancel(inner_rd.id, email)
    end

    it "sets active to false" do
      expect(rd["active"]).to eq false
    end

    it "sets cancelled_at to today" do
      expect(rd["cancelled_at"].to_date.end_of_day).to eq(Time.now.end_of_day)
    end

    it "sets the cancelled_by to the given email" do
      expect(rd["cancelled_by"]).to eq email
    end

    it "returns the full fetch_for_edit data" do
      expect(rd["nonprofit_name"]).to eq np.name
    end

    it "creates a supporter note table describing the cancellation" do
      note = Qx.select(:content).from(:supporter_notes).limit(1).order_by("id DESC").execute.first
      expect(note["content"]).to include("cancelled")
    end
  end

  describe ".update_amount" do
    include_context :shared_rd_donation_value_context

    let(:common_builder_expanded) do
      {
        "supporter" => supporter_builder_expanded,
        "nonprofit" => np_builder_expanded
      }
    end
    let(:supporter_builder_expanded) do
      supporter_to_builder_base.merge({"name" => "Fake Supporter Name"})
    end
    let(:np_builder_expanded) do
      {
        "id" => nonprofit.id,
        "name" => nonprofit.name,
        "object" => "nonprofit"
      }
    end

    describe "param validation" do
      it "rejects totally invalid data" do
        expect { UpdateRecurringDonations.update_amount(nil, nil, nil) }
          .to(raise_error do |error|
            expect(error).to be_a ParamValidation::ValidationError
            expect_validation_errors(error, [{key: "rd", name: :required},
              {key: "rd", name: :is_a},
              {key: :token, name: :required},
              {key: :token, name: :format},
              {key: "amount", name: :required},
              {key: "amount", name: :is_integer},
              {key: "amount", name: :min}])
          end)
      end
    end

    describe "token validation" do
      it "invalid token errors" do
        validation_invalid_token { UpdateRecurringDonations.update_amount(recurring_donation, fake_uuid, 500) }
      end

      it "unauthorized token errors" do
        validation_unauthorized { UpdateRecurringDonations.update_amount(recurring_donation, fake_uuid, 500) }
      end

      it "validation expired errors" do
        validation_expired { UpdateRecurringDonations.update_amount(recurring_donation, fake_uuid, 500) }
      end
    end

    describe "validate entities" do
      it "errors when rd is cancelled" do
        error_when_rd_cancelled { UpdateRecurringDonations.update_amount(recurring_donation, source_token.id, 500) }
      end

      it "errors when card is deleted" do
        error_when_card_deleted { UpdateRecurringDonations.update_amount(recurring_donation, source_token.id, 500) }
      end

      it "errors when card holder and supporter arent the same" do
        errors_when_card_holder_and_supporter_neq { UpdateRecurringDonations.update_amount(recurring_donation, other_source_token.id, 500) }
      end
    end

    it "changes amount properly" do
      recurring_donation.n_failures = 2
      recurring_donation.save!
      recurrence
      orig_recurrence = recurring_donation.recurrence

      orig_rd = recurring_donation.attributes.with_indifferent_access
      orig_donation = recurring_donation.donation.attributes.with_indifferent_access
      expect(Houdini.event_publisher).to receive(:announce).with(:recurrence_updated, {
        "id" => match_houid("objevt"),
        "object" => "object_event",
        "type" => "recurrence.updated",
        "data" => {
          "object" => common_builder_expanded.merge({
            "object" => "recurrence",
            "id" => orig_recurrence.id,
            "start_date" => orig_recurrence.start_date.to_i,
            "recurrences" => [
              {
                "start" => orig_recurrence.start_date.beginning_of_day.to_i,
                "interval" => 1,
                "type" => "monthly"
              }
            ],
            "invoice_template" => {
              "supporter" => supporter.id,
              "amount" => {"cents" => 1000, "currency" => "usd"},
              "payment_method" => {"type" => "stripe"},
              "trx_assignments" => [
                {
                  "assignment_object" => "donation",
                  "designation" => nil,
                  "amount" => {"cents" => 1000, "currency" => "usd"}
                }
              ]
            }
          })
        }
      })

      result = nil
      expect {
        result = UpdateRecurringDonations.update_amount(recurring_donation,
          source_token.token, 1000)
      }.to have_enqueued_job(RecurringDonationChangeAmountJob).with(recurring_donation, orig_rd["amount"])

      expectations = {
        donation: orig_donation.merge(amount: 1000, card_id: source_token.tokenizable.id),
        recurring_donation: orig_rd.merge(amount: 1000, n_failures: 0, start_date: Time.current.to_date)
      }

      expect(result.attributes).to eq expectations[:recurring_donation]

      recurring_donation.reload
      donation_for_rd.reload

      expect(recurring_donation.attributes).to eq expectations[:recurring_donation]
      expect(donation_for_rd.attributes).to eq expectations[:donation]
    end
  end

  describe ".update_card_id" do
    include_context :shared_rd_donation_value_context

    describe "basic validation" do
      it "basic param validation" do
        expect { UpdateRecurringDonations.update_card_id(nil, nil) }.to raise_error { |e|
          expect(e).to be_a ParamValidation::ValidationError
          expect_validation_errors(e.data, [
            {key: :rd, name: :is_hash},
            {key: :rd, name: :required},
            {key: :token, name: :required},
            {key: :token, name: :format}
          ])
        }
      end

      it "rd[:id] validation" do
        expect { UpdateRecurringDonations.update_card_id({}, fake_uuid) }.to raise_error { |e|
          expect(e).to be_a ParamValidation::ValidationError
          expect_validation_errors(e.data, [
            {key: :id, name: :is_reference},
            {key: :id, name: :required}
          ])
        }
      end
    end

    describe "token validation" do
      it "invalid token errors" do
        validation_invalid_token { UpdateRecurringDonations.update_card_id({id: 555}, fake_uuid) }
      end

      it "unauthorized token errors" do
        validation_unauthorized { UpdateRecurringDonations.update_card_id({id: 555}, fake_uuid) }
      end

      it "validation expired errors" do
        validation_expired { UpdateRecurringDonations.update_card_id({id: 555}, fake_uuid) }
      end
    end

    describe "entity retrieval errors" do
      it "find error on recurring donation" do
        find_error_recurring_donation { UpdateRecurringDonations.update_card_id({id: 55_555}, source_token.token) }
      end
    end

    it "finishes properly" do
      expect(InsertSupporterNotes).to receive(:create).with([{content: "This supporter updated their card for their recurring donation with ID #{recurring_donation.id}", supporter_id: supporter.id, user_id: 540}])
      recurring_donation.n_failures = 2
      recurring_donation.save!
      orig_rd = recurring_donation.attributes.with_indifferent_access
      orig_donation = recurring_donation.donation.attributes.with_indifferent_access

      result = UpdateRecurringDonations.update_card_id({id: recurring_donation.id}, source_token.token)

      expectations = {
        donation: orig_donation.merge(card_id: card.id),
        recurring_donation: orig_rd.merge(n_failures: 0, start_date: DateTime.now)
      }

      expectations[:result] = expectations[:recurring_donation].merge(nonprofit_name: nonprofit.name, card_name: card.name)
      expectations[:result][:start_date] = expectations[:result]["start_date"].to_date.strftime("%Y-%m-%d")
      expectations[:result][:created_at] = expectations[:result]["created_at"].to_date
      expectations[:result][:updated_at] = expectations[:result]["updated_at"].to_date

      expect(result).to match expectations[:result]

      donation_for_rd.reload
      recurring_donation.reload

      expect(recurring_donation.attributes).to eq expectations[:recurring_donation]
      expect(donation_for_rd.attributes).to eq expectations[:donation]
    end
  end

  def find_error_recurring_donation
    expect { yield() }.to raise_error { |e|
      expect(e).to be_a ParamValidation::ValidationError
      expect_validation_errors(e.data, [{key: :id}])
    }
  end

  def error_when_rd_cancelled
    recurring_donation.cancelled_at = Time.now
    recurring_donation.save!

    expect { yield() }.to raise_error { |e|
      expect(e).to be_a ParamValidation::ValidationError
      expect_validation_errors(e.data, [{key: :id}])
      expect(e.message).to eq "Recurring Donation #{recurring_donation.id} is already cancelled."
    }
  end

  def error_when_card_deleted
    card.deleted = true
    card.save!

    expect { yield() }.to raise_error { |e|
      expect(e).to be_a ParamValidation::ValidationError
      expect_validation_errors(e.data, [{key: :token}])
      expect(e.message).to eq "Tokenized card #{card.id} is not valid."
    }
  end

  def errors_when_card_holder_and_supporter_neq
    expect { yield() }.to raise_error { |e|
      expect(e).to be_a ParamValidation::ValidationError
      expect_validation_errors(e.data, [{key: :token}])
      expect(e.message).to eq "Supporter #{supporter.id} does not own card #{other_source_token.tokenizable.id}"
    }
  end
end
