# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"

describe UpdateDonation do
  before do
    Timecop.freeze(2020, 2, 3)
  end

  after do
    Timecop.return
  end

  let(:np) { force_create(:nm_justice) }
  let(:supporter) { force_create(:supporter) }
  let(:donation) do
    force_create(:donation, nonprofit: np,
      dedication: initial_dedication,
      comment: initial_comment,
      designation: initial_designation,
      amount: initial_amount,
      date: initial_date,
      supporter: supporter)
  end

  let(:trx) {
    trx = force_create(:transaction, supporter: supporter, amount: initial_amount)
    trx.donations.create(amount: initial_amount, legacy_donation: donation)

    trx
  }

  let(:payment) do
    force_create(:payment, nonprofit: np, donation: donation,
      towards: initial_designation,
      date: initial_date,
      gross_amount: initial_amount,
      fee_total: initial_fee,
      net_amount: initial_amount - initial_fee,
      supporter: supporter)
  end
  let(:offsite_payment) do
    force_create(:offsite_payment, payment: payment, nonprofit: np, donation: donation,
      check_number: initial_check_number,
      gross_amount: initial_amount,
      date: initial_date,
      supporter: supporter)
  end

  let(:payment2) do
    force_create(:payment, nonprofit: np, donation: donation,
      towards: initial_designation,
      date: payment2_date,
      gross_amount: initial_amount,
      fee_total: initial_fee,
      net_amount: initial_amount - initial_fee)
  end
  let(:campaign) { force_create(:campaign) }
  let(:event) { force_create(:event) }
  let(:other_campaign) { force_create(:campaign, nonprofit: force_create(:fv_poverty)) }
  let(:other_event) { force_create(:event, nonprofit: force_create(:fv_poverty)) }

  let(:initial_date) { Date.new(2020, 4, 5).to_time }
  let(:initial_dedication) { "initial dedication" }
  let(:initial_comment) { "comment" }
  let(:initial_amount) { 4000 }
  let(:initial_designation) { "designation" }
  let(:initial_fee) { 555 }
  let(:initial_check_number) { "htoajmioeth" }

  let(:new_date_input) { "2020-05-05" }
  let(:new_date) { Date.new(2020, 5, 5) }
  let(:new_dedication) { "new dedication" }
  let(:new_comment) { "new comment" }
  let(:new_amount) { 5646 }
  let(:new_designation) { "new designation" }
  let(:new_fee) { 54 }
  let(:new_check_number) { "new check number" }

  let(:initial_time) { Time.now }

  let(:payment2_date) { initial_date + 10.days }

  before do
    allow(Houdini.event_publisher).to receive(:announce)
    initial_time
    payment
  end

  describe ".update_payment" do
    describe "param validation" do
      it "basic validation" do
        expect(Houdini.event_publisher).to_not receive(:announce).with(:donation_updated, anything)
        expect { UpdateDonation.update_payment(nil, nil) }.to raise_error { |error|
          expect(error).to be_a ParamValidation::ValidationError
          expect_validation_errors(error.data, [{key: :id, name: :required},
            {key: :id, name: :is_reference},
            {key: :data, name: :required},
            {key: :data, name: :is_hash}])
        }
      end

      it "validates whether payment is valid" do
        expect(Houdini.event_publisher).to_not receive(:announce).with(:donation_updated, anything)
        expect { UpdateDonation.update_payment(5555, {}) }.to raise_error { |error|
          expect(error).to be_a ParamValidation::ValidationError
          expect_validation_errors(error.data, [{key: :id}])
          expect(error.message).to eq "5555 is does not correspond to a valid donation"
        }
      end

      describe "data validation" do
        let(:initial_invalid_arguments) do
          {
            designation: 1,
            dedication: 1,
            comment: 1,
            campaign_id: nil,
            event_id: nil
          }
        end

        let(:expanded_invalid_arguments) do
          initial_invalid_arguments.merge(
            fee_total: "fun",
            gross_amount: "fun",
            check_number: Time.now,
            date: "INVALID DATE"
          )
        end

        let(:initial_validation_errors) do
          [
            {key: :designation, name: :is_a},
            {key: :dedication, name: :is_a},
            {key: :comment, name: :is_a},
            {key: :campaign_id, name: :is_reference},
            {key: :campaign_id, name: :required},
            {key: :event_id, name: :is_reference},
            {key: :event_id, name: :required}
          ]
        end

        it "for offsite donations" do
          offsite_payment
          expect(Houdini.event_publisher).to_not receive(:announce).with(:donation_updated, anything)
          expect { UpdateDonation.update_payment(donation.id, expanded_invalid_arguments) }.to(raise_error do |error|
            expect(error).to be_a ParamValidation::ValidationError
            expect_validation_errors(error.data, initial_validation_errors.concat([

              {key: :fee_total, name: :is_integer},
              {key: :gross_amount, name: :is_integer},
              {key: :gross_amount, name: :min},
              {key: :check_number, name: :is_a},
              {key: :date, name: :can_be_date}
            ]))
          end)
        end

        it "for online donation" do
          expect(Houdini.event_publisher).to_not receive(:announce).with(:donation_updated, anything)
          expect { UpdateDonation.update_payment(donation.id, expanded_invalid_arguments) }.to(raise_error do |error|
            expect(error).to be_a ParamValidation::ValidationError
            expect_validation_errors(error.data, initial_validation_errors)
          end)
        end
      end

      it "validate campaign_id" do
        expect(Houdini.event_publisher).to_not receive(:announce).with(:donation_updated, anything)
        expect { UpdateDonation.update_payment(donation.id, campaign_id: 444, event_id: 444) }.to(raise_error do |error|
          expect(error).to be_a ParamValidation::ValidationError
          expect_validation_errors(error.data, [{key: :campaign_id}])
        end)
      end

      it "validate event_id" do
        expect(Houdini.event_publisher).to_not receive(:announce).with(:donation_updated, anything)
        expect { UpdateDonation.update_payment(donation.id, event_id: 4444, campaign_id: campaign.id) }.to(raise_error do |error|
          expect(error).to be_a ParamValidation::ValidationError
          expect_validation_errors(error.data, [{key: :event_id}])
        end)
      end

      it "validates campaign belongs to payment org" do
        expect(Houdini.event_publisher).to_not receive(:announce).with(:donation_updated, anything)
        campaign_belongs { UpdateDonation.update_payment(donation.id, campaign_id: other_campaign.id, event_id: event.id) }
      end

      it "validates event belongs to payment org" do
        expect(Houdini.event_publisher).to_not receive(:announce).with(:donation_updated, anything)
        event_belongs { UpdateDonation.update_payment(donation.id, event_id: other_event.id, campaign_id: campaign.id) }
      end
    end

    describe "most of the values arent changed if not provided" do
      it "online donation" do
        trx
        payment2
        result = verify_nothing_changed
        expect(Houdini.event_publisher).to_not receive(:announce).with(:donation_updated, anything)
        expect(result).to eq donation.attributes.merge(payment: payment2.attributes)
        trx.reload
        expect(trx.amount).to eq initial_amount
        expect(trx.donations.first.amount).to eq initial_amount
      end

      it "offsite donation" do
        trx
        offsite_payment
        result = verify_nothing_changed
        expect(Houdini.event_publisher).to_not receive(:announce).with(:donation_updated, anything)
        p2_attributes = payment2.attributes
        payment2.reload
        expect(p2_attributes).to eq payment2.attributes

        o_attributes = offsite_payment.attributes
        offsite_payment.reload
        expect(o_attributes).to eq offsite_payment.attributes
        expect(result).to eq donation.attributes.merge(payment: payment.attributes, offsite_payment: offsite_payment.attributes)
        trx.reload
        expect(trx.amount).to eq initial_amount
        expect(trx.donations.first.amount).to eq initial_amount
      end

      def verify_nothing_changed
        expect(Houdini.event_publisher).to_not receive(:announce).with(:donation_updated, anything)
        result = UpdateDonation.update_payment(donation.id, campaign_id: "", event_id: "")

        p_attributes = payment.attributes
        payment.reload
        expect(p_attributes).to eq payment.attributes

        d_attributes = donation.attributes
        donation.reload
        expect(d_attributes).to eq donation.attributes

        trx.reload
        expect(trx.amount).to eq initial_amount
        expect(trx.donations.first.amount).to eq initial_amount
        result
      end
    end

    describe "test everything changed" do
      let(:new_data) do
        {designation: new_designation,
         dedication: new_dedication,
         comment: new_comment,
         campaign_id: campaign.id,
         event_id: event.id,

         gross_amount: new_amount,
         fee_total: new_fee,
         check_number: new_check_number,
         date: new_date_input}
      end

      it "online donation" do
        trx
        payment2
        Timecop.freeze(1.day) do
          expect(Houdini.event_publisher).to receive(:announce).with(:donation_updated, anything)
          result = UpdateDonation.update_payment(donation.id, new_data)

          expected_donation = donation.attributes.merge(designation: new_designation,
            dedication: new_dedication,
            comment: new_comment,
            campaign_id: campaign.id,
            event_id: event.id,
            updated_at: Time.now).with_indifferent_access

          donation.reload
          expect(donation.attributes).to eq expected_donation

          expected_p1 = payment.attributes.merge(towards: new_designation, updated_at: Time.now).with_indifferent_access
          payment.reload
          expect(payment.attributes).to eq expected_p1

          expected_p2 = payment2.attributes.merge(towards: new_designation, updated_at: Time.now).with_indifferent_access

          payment2.reload
          expect(payment2.attributes).to eq expected_p2

          expected_offsite = offsite_payment.attributes
          offsite_payment.reload
          expect(offsite_payment.attributes).to eq expected_offsite

          expect(result).to eq create_expected_result(donation, payment2)
        end
      end

      it "offline donation" do
        trx
        offsite_payment
        Timecop.freeze(1.day) do
          expect(Houdini.event_publisher).to receive(:announce).with(:donation_updated, anything)
          result = UpdateDonation.update_payment(donation.id, new_data)

          expected_donation = donation.attributes.merge(
            date: new_date,
            amount: new_amount,

            designation: new_designation,
            dedication: new_dedication,
            comment: new_comment,

            campaign_id: campaign.id,
            event_id: event.id,
            updated_at: Time.now
          ).with_indifferent_access

          trx.reload
          donation.reload
          expect(donation.attributes).to eq expected_donation

          expected_p1 = payment.attributes.merge(towards: new_designation, updated_at: Time.now, date: new_date, gross_amount: new_amount, fee_total: new_fee, net_amount: new_amount - new_fee).with_indifferent_access
          payment.reload
          expect(payment.attributes).to eq expected_p1

          expect(Payment.count).to eq 1

          expected_offsite_payment = offsite_payment.attributes.merge(check_number: new_check_number, date: new_date.in_time_zone, gross_amount: new_amount, updated_at: Time.now).with_indifferent_access

          offsite_payment.reload
          expect(offsite_payment.attributes).to eq expected_offsite_payment

          expect(result).to eq create_expected_result(donation, payment, offsite_payment)

          expect(trx.amount).to eq new_amount

          expect(trx.donations.first.amount).to eq new_amount
        end
      end

      describe "test blank but existent data will rewrite" do
        let(:blank_data) do
          {designation: "",
           dedication: "",
           comment: "",
           campaign_id: "",
           event_id: "",

           gross_amount: new_amount,
           fee_total: new_fee,
           check_number: "",
           date: new_date_input}
        end

        it "online donation" do
          trx
          payment2
          Timecop.freeze(1.day) do
            expect(Houdini.event_publisher).to receive(:announce).with(:donation_updated, anything)
            UpdateDonation.update_payment(donation.id, new_data)
            result = UpdateDonation.update_payment(donation.id, blank_data)

            expected_donation = donation.attributes.merge(designation: "",
              dedication: "",
              comment: "",
              campaign_id: nil,
              event_id: nil,
              updated_at: Time.now).with_indifferent_access
            donation.reload

            expect(donation.attributes).to eq expected_donation

            expected_p1 = payment.attributes.merge(towards: "", updated_at: Time.now).with_indifferent_access
            payment.reload
            expect(payment.attributes).to eq expected_p1

            expected_p2 = payment2.attributes.merge(towards: "", updated_at: Time.now).with_indifferent_access

            payment2.reload
            expect(payment2.attributes).to eq expected_p2

            expected_offsite = offsite_payment.attributes
            offsite_payment.reload
            expect(offsite_payment.attributes).to eq expected_offsite

            expect(result).to eq create_expected_result(donation, payment2)
          end
        end

        it "offline donation" do
          trx
          offsite_payment
          Timecop.freeze(1.day) do
            expect(Houdini.event_publisher).to receive(:announce).with(:donation_updated, anything)
            UpdateDonation.update_payment(donation.id, new_data)
            result = UpdateDonation.update_payment(donation.id, blank_data)

            expected_donation = donation.attributes.merge(
              date: new_date.in_time_zone,
              amount: new_amount,

              designation: "",
              dedication: "",
              comment: "",

              campaign_id: nil,
              event_id: nil,
              updated_at: Time.now
            ).with_indifferent_access

            donation.reload
            expect(donation.attributes).to eq expected_donation

            expected_p1 = payment.attributes.merge(towards: "", updated_at: Time.now, date: new_date.in_time_zone, gross_amount: new_amount, fee_total: new_fee, net_amount: new_amount - new_fee).with_indifferent_access
            payment.reload
            expect(payment.attributes).to eq expected_p1

            expect(Payment.count).to eq 1

            expected_offsite_payment = offsite_payment.attributes.merge(check_number: "", date: new_date.in_time_zone, gross_amount: new_amount, updated_at: Time.now).with_indifferent_access

            offsite_payment.reload
            expect(offsite_payment.attributes).to eq expected_offsite_payment

            expect(result).to eq create_expected_result(donation, payment, offsite_payment)
          end
        end
      end
    end
  end

  def event_belongs
    expect { yield }.to(raise_error do |error|
      expect(error).to be_a ParamValidation::ValidationError
      expect_validation_errors(error.data, [{key: :event_id}])
      expect(error.message).to include "event does not belong to this nonprofit"
    end)
  end

  def campaign_belongs
    expect { yield }.to(raise_error do |error|
      expect(error).to be_a ParamValidation::ValidationError
      expect_validation_errors(error.data, [{key: :campaign_id}])
      expect(error.message).to include "campaign does not belong to this nonprofit"
    end)
  end

  def create_expected_result(donation, payment, offsite_payment = nil)
    ret = donation.attributes
    ret[:payment] = payment.attributes
    ret[:offsite_payment] = offsite_payment.attributes if offsite_payment

    ret
  end
end
