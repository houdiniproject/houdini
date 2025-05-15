# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

describe UpdateRecurringDonations do
  let!(:automated_user) { create(:automated_user) }
  # deactivate a recurring donation
  describe ".cancel" do
    let(:np) { force_create(:nonprofit) }
    let(:s) { force_create(:supporter) }
    let(:donation) { create(:donation, nonprofit_id: np.id, supporter_id: s.id, amount: 999) }
    let(:email) { "test@test.com" }
    let!(:rd) {
      inner_rd = create(:recurring_donation_base, amount: 999, active: true, supporter_id: s.id, donation_id: donation.id, nonprofit_id: np.id)
      UpdateRecurringDonations.cancel(inner_rd.id, email)
    }

    it "sets active to false" do
      expect(rd["active"]).to eq false
    end

    it "sets cancelled_at to today" do
      expect(rd["cancelled_at"].end_of_day).to eq(Time.current.end_of_day)
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

      orig_rd = recurring_donation.attributes.with_indifferent_access
      orig_donation = recurring_donation.donation.attributes.with_indifferent_access

      expect_job_queued.with(JobTypes::DonorRecurringDonationChangeAmountJob, recurring_donation.id, orig_rd["amount"])
      expect_job_queued.with(JobTypes::NonprofitRecurringDonationChangeAmountJob, recurring_donation.id, orig_rd["amount"])

      result = UpdateRecurringDonations.update_amount(recurring_donation, source_token.token, 1000)

      expectations = {
        donation: orig_donation.merge(amount: 1000, card_id: source_token.tokenizable.id, fts: ""),
        recurring_donation: orig_rd.merge(amount: 1000, n_failures: 0, start_date: Time.current.to_date)
      }

      expect(result.attributes).to eq expectations[:recurring_donation]

      recurring_donation.reload
      donation_for_rd.reload

      expect(recurring_donation.attributes).to eq expectations[:recurring_donation]
      expect(donation_for_rd.attributes).to eq expectations[:donation]

      expect(recurring_donation.misc_recurring_donation_info.fee_covered).to eq false
    end

    it "changes amount properly and marks as fee_covered" do
      recurring_donation.n_failures = 2
      recurring_donation.save!

      orig_rd = recurring_donation.attributes.with_indifferent_access
      orig_donation = recurring_donation.donation.attributes.with_indifferent_access

      expect_job_queued.with(JobTypes::DonorRecurringDonationChangeAmountJob, recurring_donation.id, orig_rd["amount"])
      expect_job_queued.with(JobTypes::NonprofitRecurringDonationChangeAmountJob, recurring_donation.id, orig_rd["amount"])

      result = UpdateRecurringDonations.update_amount(recurring_donation, source_token.token, 1000, true)

      expectations = {
        donation: orig_donation.merge(amount: 1000, card_id: source_token.tokenizable.id, fts: ""),
        recurring_donation: orig_rd.merge(amount: 1000, n_failures: 0, start_date: Time.current.to_date)
      }

      expect(result.attributes).to eq expectations[:recurring_donation]

      recurring_donation.reload
      donation_for_rd.reload

      expect(recurring_donation.attributes).to eq expectations[:recurring_donation]
      expect(recurring_donation.misc_recurring_donation_info.fee_covered).to eq true
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
        find_error_recurring_donation { UpdateRecurringDonations.update_card_id({id: 55555}, source_token.token) }
      end
    end

    it "finishes properly" do
      recurring_donation.n_failures = 2
      recurring_donation.save!
      orig_rd = recurring_donation.attributes.with_indifferent_access
      orig_donation = recurring_donation.donation.attributes.with_indifferent_access

      result = UpdateRecurringDonations.update_card_id({id: recurring_donation.id}, source_token.token)
      expectations = {

        donation: orig_donation.merge(card_id: card.id, fts: ""),
        recurring_donation: orig_rd.merge(n_failures: 0, start_date: Time.now.to_date)
      }

      expectations[:result] = expectations[:recurring_donation].merge(nonprofit_name: nonprofit.name, card_name: card.name)
      expect(result).to eq expectations[:result]
      donation_for_rd.reload
      recurring_donation.reload

      expect(recurring_donation.supporter.supporter_notes.last).to have_attributes(content: "This supporter updated their card for their recurring donation with ID #{recurring_donation.id}", user_id: 540)
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
