# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

describe PaymentDupes, skip: true do # this was a one-off
  let(:nonprofit) { create(:fv_poverty, timezone: "America/Chicago", vetted: true) }
  let(:supporter) { create(:supporter, nonprofit: nonprofit) }
  let!(:etap_import) { create(:e_tap_import, nonprofit: nonprofit) }

  describe "#can_copy_dedication?" do
    context "when the source donation has an empty dedication" do
      it "returns true" do
        source_donation = nonprofit.donations.create(dedication: "", amount: 100, supporter: supporter)
        source_donation.save!
        source_payment = source_donation.payments.create(nonprofit: nonprofit)
        source_payment.save!

        target_donation = nonprofit.donations.create(dedication: "Some dedication", amount: 100, supporter: supporter)
        target_donation.save!
        target_payment = target_donation.payments.create(nonprofit: nonprofit)
        target_payment.save!

        expect(described_class.can_copy_dedication?(source_payment, target_payment)).to be_truthy
      end
    end

    context "when the target donation has a dedication" do
      context "and the dedication is the same for both target and source donations" do
        it "returns true" do
          target_donation = nonprofit.donations.create(dedication: "Some dedication", amount: 100, supporter: supporter)
          target_donation.save!
          target_payment = target_donation.payments.create(nonprofit: nonprofit)
          target_payment.save!

          source_donation = nonprofit.donations.create(dedication: "Some dedication", amount: 100, supporter: supporter)
          source_donation.save!
          source_payment = source_donation.payments.create(nonprofit: nonprofit)
          source_payment.save!

          expect(described_class.can_copy_dedication?(source_payment, target_payment)).to be_truthy
        end
      end

      context "and the dedication is different for both target and source donations" do
        it "returns false" do
          target_donation = nonprofit.donations.create(dedication: "Some dedication", amount: 100, supporter: supporter)
          target_donation.save!
          target_payment = target_donation.payments.create(nonprofit: nonprofit)
          target_payment.save!

          source_donation = nonprofit.donations.create(dedication: "Some other dedication", amount: 100, supporter: supporter)
          source_donation.save!
          source_payment = source_donation.payments.create(nonprofit: nonprofit)
          source_payment.save!

          expect(described_class.can_copy_dedication?(source_payment, target_payment)).to be_falsy
        end
      end
    end
  end

  describe "#can_copy_designation?" do
    context "when the source donation has an empty dedication" do
      it "returns true" do
        source_donation = nonprofit.donations.create(designation: "", amount: 100, supporter: supporter)
        source_donation.save!
        source_payment = source_donation.payments.create(nonprofit: nonprofit)
        source_payment.save!

        target_donation = nonprofit.donations.create(designation: "Some designation", amount: 100, supporter: supporter)
        target_donation.save!
        target_payment = target_donation.payments.create(nonprofit: nonprofit)
        target_payment.save!

        expect(described_class.can_copy_designation?(source_payment, target_payment, ["A designation that should become a comment"])).to be_truthy
      end
    end

    context "when the target donation has a designation" do
      context "and the designation is the same for both target and source donations" do
        it "returns true" do
          target_donation = nonprofit.donations.create(designation: "Some designation", amount: 100, supporter: supporter)
          target_donation.save!
          target_payment = target_donation.payments.create(nonprofit: nonprofit)
          target_payment.save!

          source_donation = nonprofit.donations.create(designation: "Some designation", amount: 100, supporter: supporter)
          source_donation.save!
          source_payment = source_donation.payments.create(nonprofit: nonprofit)
          source_payment.save!

          expect(described_class.can_copy_designation?(source_payment, target_payment, ["A designation that should become a comment"])).to be_truthy
        end
      end

      context "and the designation is different for both target and source donations" do
        it "returns false" do
          target_donation = nonprofit.donations.create(designation: "Some designation", amount: 100, supporter: supporter)
          target_donation.save!
          target_payment = target_donation.payments.create(nonprofit: nonprofit)
          target_payment.save!

          source_donation = nonprofit.donations.create(designation: "Some other designation", amount: 100, supporter: supporter)
          source_donation.save!
          source_payment = source_donation.payments.create(nonprofit: nonprofit)
          source_payment.save!

          expect(described_class.can_copy_designation?(source_payment, target_payment, ["A designation that should become a comment"])).to be_falsy
        end

        context "and the designation is one that should become a comment" do
          it "returns true" do
            target_donation = nonprofit.donations.create(designation: "Some designation", amount: 100, supporter: supporter)
            target_donation.save!
            target_payment = target_donation.payments.create(nonprofit: nonprofit)
            target_payment.save!

            source_donation = nonprofit.donations.create(designation: "A designation that should become a comment", amount: 100, supporter: supporter)
            source_donation.save!
            source_payment = source_donation.payments.create(nonprofit: nonprofit)
            source_payment.save!

            expect(described_class.can_copy_designation?(source_payment, target_payment, ["A designation that should become a comment"])).to be_truthy
          end
        end
      end
    end
  end

  describe "#can_copy_comment?" do
    context "when the source donation has an empty comment" do
      it "returns true" do
        source_donation = nonprofit.donations.create(comment: "", amount: 100, supporter: supporter)
        source_donation.save!
        source_payment = source_donation.payments.create(nonprofit: nonprofit)
        source_payment.save!

        target_donation = nonprofit.donations.create(comment: "Some comment", amount: 100, supporter: supporter)
        target_donation.save!
        target_payment = target_donation.payments.create(nonprofit: nonprofit)
        target_payment.save!

        expect(described_class.can_copy_comment?(source_payment, target_payment, ["A designation to become a comment"])).to be_truthy
      end
    end

    context "when the target donation has a comment" do
      context "and the comment is the same for both target and source donations" do
        it "returns true" do
          target_donation = nonprofit.donations.create(comment: "Some comment", amount: 100, supporter: supporter)
          target_donation.save!
          target_payment = target_donation.payments.create(nonprofit: nonprofit)
          target_payment.save!

          source_donation = nonprofit.donations.create(comment: "Some comment", amount: 100, supporter: supporter)
          source_donation.save!
          source_payment = source_donation.payments.create(nonprofit: nonprofit)
          source_payment.save!

          expect(described_class.can_copy_comment?(source_payment, target_payment, ["A designation to become a comment"])).to be_truthy
        end
      end

      context "and the comment is different for both target and source donations" do
        context "because a designation was copied to the comment" do
          it "returns true if the only difference is the designation that was added to the comment" do
            target_donation = nonprofit.donations.create(comment: "Some comment \nDesignation: A designation to become a comment", amount: 100, supporter: supporter)
            target_donation.save!
            target_payment = target_donation.payments.create(nonprofit: nonprofit)
            target_payment.save!

            source_donation = nonprofit.donations.create(comment: "Some comment", amount: 100, supporter: supporter)
            source_donation.save!
            source_payment = source_donation.payments.create(nonprofit: nonprofit)
            source_payment.save!

            expect(described_class.can_copy_comment?(source_payment, target_payment, ["A designation to become a comment"])).to be_truthy
          end

          it "returns false if its not the only difference" do
            target_donation = nonprofit.donations.create(comment: "Some other comment \nDesignation: A designation to become a comment", amount: 100, supporter: supporter)
            target_donation.save!
            target_payment = target_donation.payments.create(nonprofit: nonprofit)
            target_payment.save!

            source_donation = nonprofit.donations.create(comment: "Some comment", amount: 100, supporter: supporter)
            source_donation.save!
            source_payment = source_donation.payments.create(nonprofit: nonprofit)
            source_payment.save!

            expect(described_class.can_copy_comment?(source_payment, target_payment, ["A designation to become a comment"])).to be_falsy
          end
        end

        it "returns false" do
          target_donation = nonprofit.donations.create(comment: "Some comment", amount: 100, supporter: supporter)
          target_donation.save!
          target_payment = target_donation.payments.create(nonprofit: nonprofit)
          target_payment.save!

          source_donation = nonprofit.donations.create(comment: "Some other comment", amount: 100, supporter: supporter)
          source_donation.save!
          source_payment = source_donation.payments.create(nonprofit: nonprofit)
          source_payment.save!

          expect(described_class.can_copy_comment?(source_payment, target_payment, ["A designation to become a comment"])).to be_falsy
        end
      end
    end
  end

  describe "#remove_payment_dupes" do
    before do
      InsertCustomFieldJoins.find_or_create(nonprofit.id, [supporter.id], [["E-Tapestry Id #", "123"]])
    end

    around(:each) do |example|
      Timecop.freeze(Time.local(2022, 2, 9)) do
        example.run
      end
    end

    context "when there is a payment and an offsite payment with the same data" do
      it "deletes the offsite payment" do
        source_donation = nonprofit.donations.create(comment: "", amount: 100, supporter: supporter)
        source_donation.save!
        source_payment = source_donation.payments.create(nonprofit: nonprofit, kind: "OffsitePayment", date: Time.now, supporter: supporter, gross_amount: 100)
        source_payment.save!

        target_donation = nonprofit.donations.create(comment: "Some comment", amount: 100, supporter: supporter)
        target_donation.save!
        target_payment = target_donation.payments.create(nonprofit: nonprofit, date: Time.now, kind: "Donation", supporter: supporter, gross_amount: 100)
        target_payment.save!

        etap_import.e_tap_import_journal_entries.create(row: {"Account Number" => "123"})
        etap_import.e_tap_import_journal_entries.first.journal_entries_to_items.create(item: source_payment).save!

        described_class.remove_payment_dupes(nonprofit, ["A designation that should become a comment"])
        expect { source_payment.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end

      context "when the donor covered the fee" do
        it "deletes the offsite payment based on the net amount" do
          source_donation = nonprofit.donations.create(comment: "", amount: 100, supporter: supporter)
          source_donation.save!
          source_payment = source_donation.payments.create(nonprofit: nonprofit, kind: "OffsitePayment", date: Time.now, supporter: supporter, gross_amount: 100)
          source_payment.save!

          target_donation = nonprofit.donations.create(comment: "Some comment", amount: 100, supporter: supporter)
          target_donation.save!
          target_payment = target_donation.payments.create(nonprofit: nonprofit, date: Time.now, kind: "Donation", supporter: supporter, gross_amount: 95, fee_total: -5, net_amount: 100)
          target_payment.save!

          etap_import.e_tap_import_journal_entries.create(row: {"Account Number" => "123"})
          etap_import.e_tap_import_journal_entries.first.journal_entries_to_items.create(item: source_payment).save!

          described_class.remove_payment_dupes(nonprofit, ["A designation that should become a comment"])
          expect { source_payment.reload }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context "payments saved under different timezones" do
        it "matches if the dates are different because of different timezones" do
          source_donation = nonprofit.donations.create(comment: "", amount: 100, supporter: supporter)
          source_donation.save!
          source_payment = source_donation.payments.create(nonprofit: nonprofit, kind: "OffsitePayment", date: Time.new(2021, 5, 24, 5, 0, 0), supporter: supporter, gross_amount: 100)
          source_payment.save!

          target_donation = nonprofit.donations.create(comment: "Some comment", amount: 100, supporter: supporter)
          target_donation.save!
          target_payment = target_donation.payments.create(nonprofit: nonprofit, date: Time.new(2021, 5, 25, 1, 0, 0), kind: "Donation", supporter: supporter, gross_amount: 100)
          target_payment.save!

          etap_import.e_tap_import_journal_entries.create(row: {"Account Number" => "123"})
          etap_import.e_tap_import_journal_entries.first.journal_entries_to_items.create(item: source_payment).save!

          described_class.remove_payment_dupes(nonprofit, ["A designation that should become a comment"])
          expect { source_payment.reload }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      it "creates a payment dupe status" do
        source_donation = nonprofit.donations.create(comment: "", amount: 100, supporter: supporter)
        source_donation.save!
        source_payment = source_donation.payments.create(nonprofit: nonprofit, kind: "OffsitePayment", date: Time.now, supporter: supporter, gross_amount: 100)
        source_payment.save!

        target_donation = nonprofit.donations.create(comment: "Some comment", amount: 100, supporter: supporter)
        target_donation.save!
        target_payment = target_donation.payments.create(nonprofit: nonprofit, date: Time.now, kind: "Donation", supporter: supporter, gross_amount: 100)
        target_payment.save!

        etap_import.e_tap_import_journal_entries.create(row: {"Account Number" => "123"})
        etap_import.e_tap_import_journal_entries.first.journal_entries_to_items.create(item: source_payment).save!

        described_class.remove_payment_dupes(nonprofit, ["A designation that should become a comment"])
        expect(target_payment.reload.payment_dupe_status.matched_with_offline).to eq([source_payment.id])
      end

      it "copies the dedication" do
        source_donation = nonprofit.donations.create(dedication: "A dedication", amount: 100, supporter: supporter)
        source_donation.save!
        source_payment = source_donation.payments.create(nonprofit: nonprofit, kind: "OffsitePayment", date: Time.now, supporter: supporter, gross_amount: 100)
        source_payment.save!

        target_donation = nonprofit.donations.create(dedication: "", amount: 100, supporter: supporter)
        target_donation.save!
        target_payment = target_donation.payments.create(nonprofit: nonprofit, date: Time.now, kind: "Donation", supporter: supporter, gross_amount: 100)
        target_payment.save!

        etap_import.e_tap_import_journal_entries.create(row: {"Account Number" => "123"})
        etap_import.e_tap_import_journal_entries.first.journal_entries_to_items.create(item: source_payment).save!

        described_class.remove_payment_dupes(nonprofit, ["A designation that should become a comment"])
        expect(target_payment.reload.donation.dedication).to eq("A dedication")
      end

      it "copies the comment" do
        source_donation = nonprofit.donations.create(comment: "A comment", amount: 100, supporter: supporter)
        source_donation.save!
        source_payment = source_donation.payments.create(nonprofit: nonprofit, kind: "OffsitePayment", date: Time.now, supporter: supporter, gross_amount: 100)
        source_payment.save!

        target_donation = nonprofit.donations.create(comment: "", amount: 100, supporter: supporter)
        target_donation.save!
        target_payment = target_donation.payments.create(nonprofit: nonprofit, date: Time.now, kind: "Donation", supporter: supporter, gross_amount: 100)
        target_payment.save!

        etap_import.e_tap_import_journal_entries.create(row: {"Account Number" => "123"})
        etap_import.e_tap_import_journal_entries.first.journal_entries_to_items.create(item: source_payment).save!

        described_class.remove_payment_dupes(nonprofit, ["A designation that should become a comment"])
        expect(target_payment.reload.donation.comment).to eq("A comment")
      end

      it "copies the designation" do
        source_donation = nonprofit.donations.create(designation: "A designation", amount: 100, supporter: supporter)
        source_donation.save!
        source_payment = source_donation.payments.create(nonprofit: nonprofit, kind: "OffsitePayment", date: Time.now, supporter: supporter, gross_amount: 100)
        source_payment.save!

        target_donation = nonprofit.donations.create(designation: "", amount: 100, supporter: supporter)
        target_donation.save!
        target_payment = target_donation.payments.create(nonprofit: nonprofit, date: Time.now, kind: "Donation", supporter: supporter, gross_amount: 100)
        target_payment.save!

        etap_import.e_tap_import_journal_entries.create(row: {"Account Number" => "123"})
        etap_import.e_tap_import_journal_entries.first.journal_entries_to_items.create(item: source_payment).save!

        described_class.remove_payment_dupes(nonprofit, ["A designation that should become a comment"])
        expect(target_payment.reload.donation.designation).to eq("A designation")
      end

      it "deletes the related activities" do
        donation = InsertDonation.offsite({:supporter_id => supporter.id, :nonprofit_id => nonprofit.id, "supporter_id" => supporter.id, "nonprofit_id" => nonprofit.id, "date" => Time.now.to_s, "amount" => 100})
        source_payment = Payment.find(donation[:json]["payment"]["id"])
        activity = Activity.where(attachment_id: source_payment.id, attachment_type: "Payment").first

        target_donation = nonprofit.donations.create(comment: "Some comment", amount: 100, supporter: supporter)
        target_donation.save!
        target_payment = target_donation.payments.create(nonprofit: nonprofit, date: Time.now, kind: "Donation", supporter: supporter, gross_amount: 100)
        target_payment.save!

        etap_import.e_tap_import_journal_entries.create(row: {"Account Number" => "123"})
        etap_import.e_tap_import_journal_entries.first.journal_entries_to_items.create(item: source_payment).save!

        described_class.remove_payment_dupes(nonprofit, ["A designation that should become a comment"])
        expect { activity.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it "deletes the offsite_payment" do
        donation = InsertDonation.offsite({:supporter_id => supporter.id, :nonprofit_id => nonprofit.id, "supporter_id" => supporter.id, "nonprofit_id" => nonprofit.id, "date" => Time.now.to_s, "amount" => 100})
        source_payment = Payment.find(donation[:json]["payment"]["id"])
        offsite = source_payment.offsite_payment

        target_donation = nonprofit.donations.create(comment: "Some comment", amount: 100, supporter: supporter)
        target_donation.save!
        target_payment = target_donation.payments.create(nonprofit: nonprofit, date: Time.now, kind: "Donation", supporter: supporter, gross_amount: 100)
        target_payment.save!

        etap_import.e_tap_import_journal_entries.create(row: {"Account Number" => "123"})
        etap_import.e_tap_import_journal_entries.first.journal_entries_to_items.create(item: source_payment).save!

        described_class.remove_payment_dupes(nonprofit, ["A designation that should become a comment"])
        expect { offsite.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end

      context "when the designation is one that should be a comment" do
        it "copies the designation as a comment" do
          source_donation = nonprofit.donations.create(designation: "A designation that should become a comment", amount: 100, supporter: supporter)
          source_donation.save!
          source_payment = source_donation.payments.create(nonprofit: nonprofit, kind: "OffsitePayment", date: Time.now, supporter: supporter, gross_amount: 100)
          source_payment.save!

          target_donation = nonprofit.donations.create(designation: "", amount: 100, supporter: supporter)
          target_donation.save!
          target_payment = target_donation.payments.create(nonprofit: nonprofit, date: Time.now, kind: "Donation", supporter: supporter, gross_amount: 100)
          target_payment.save!

          etap_import.e_tap_import_journal_entries.create(row: {"Account Number" => "123"})
          etap_import.e_tap_import_journal_entries.first.journal_entries_to_items.create(item: source_payment).save!

          described_class.remove_payment_dupes(nonprofit, ["A designation that should become a comment"])
          expect(target_payment.reload.donation.comment.include?("A designation that should become a comment")).to be_truthy
        end
      end

      context "when the dedication is conflicting" do
        it "does not delete the offline donation" do
          source_donation = nonprofit.donations.create(dedication: "Some dedication", amount: 100, supporter: supporter)
          source_donation.save!
          source_payment = source_donation.payments.create(nonprofit: nonprofit, kind: "OffsitePayment", date: Time.now, supporter: supporter, gross_amount: 100)
          source_payment.save!

          target_donation = nonprofit.donations.create(dedication: "Some other dedication", amount: 100, supporter: supporter)
          target_donation.save!
          target_payment = target_donation.payments.create(nonprofit: nonprofit, date: Time.now, kind: "Donation", supporter: supporter, gross_amount: 100)
          target_payment.save!

          etap_import.e_tap_import_journal_entries.create(row: {"Account Number" => "123"})
          etap_import.e_tap_import_journal_entries.first.journal_entries_to_items.create(item: source_payment).save!

          described_class.remove_payment_dupes(nonprofit, ["A designation that should become a comment"])
          expect { source_payment.reload }.not_to raise_error
        end
      end

      context "when the designation is conflicting" do
        it "does not delete the offline donation" do
          source_donation = nonprofit.donations.create(designation: "Some designation", amount: 100, supporter: supporter)
          source_donation.save!
          source_payment = source_donation.payments.create(nonprofit: nonprofit, kind: "OffsitePayment", date: Time.now, supporter: supporter, gross_amount: 100)
          source_payment.save!

          target_donation = nonprofit.donations.create(designation: "Some other designation", amount: 100, supporter: supporter)
          target_donation.save!
          target_payment = target_donation.payments.create(nonprofit: nonprofit, date: Time.now, kind: "Donation", supporter: supporter, gross_amount: 100)
          target_payment.save!

          etap_import.e_tap_import_journal_entries.create(row: {"Account Number" => "123"})
          etap_import.e_tap_import_journal_entries.first.journal_entries_to_items.create(item: source_payment).save!

          described_class.remove_payment_dupes(nonprofit, ["A designation that should become a comment"])
          expect { source_payment.reload }.not_to raise_error
        end
      end

      context "when the comment is conflicting" do
        it "does not delete the offline donation" do
          source_donation = nonprofit.donations.create(comment: "Some comment", amount: 100, supporter: supporter)
          source_donation.save!
          source_payment = source_donation.payments.create(nonprofit: nonprofit, kind: "OffsitePayment", date: Time.now, supporter: supporter, gross_amount: 100)
          source_payment.save!

          target_donation = nonprofit.donations.create(comment: "Some other comment", amount: 100, supporter: supporter)
          target_donation.save!
          target_payment = target_donation.payments.create(nonprofit: nonprofit, date: Time.now, kind: "Donation", supporter: supporter, gross_amount: 100)
          target_payment.save!

          etap_import.e_tap_import_journal_entries.create(row: {"Account Number" => "123"})
          etap_import.e_tap_import_journal_entries.first.journal_entries_to_items.create(item: source_payment).save!

          described_class.remove_payment_dupes(nonprofit, ["A designation that should become a comment"])
          expect { source_payment.reload }.not_to raise_error
        end
      end

      context "when the payment kind is a ticket" do
        it "deletes the offsite payment" do
          source_donation = nonprofit.donations.create(amount: 100, supporter: supporter)
          source_donation.save!
          source_payment = source_donation.payments.create(nonprofit: nonprofit, kind: "OffsitePayment", date: Time.now, supporter: supporter, gross_amount: 100)
          source_payment.save!

          target_donation = nonprofit.donations.create(amount: 100, supporter: supporter)
          target_donation.save!
          target_payment = target_donation.payments.create(nonprofit: nonprofit, date: Time.now, kind: "Ticket", supporter: supporter, gross_amount: 100)
          target_payment.save!

          etap_import.e_tap_import_journal_entries.create(row: {"Account Number" => "123"})
          etap_import.e_tap_import_journal_entries.first.journal_entries_to_items.create(item: source_payment).save!

          described_class.remove_payment_dupes(nonprofit, ["A designation that should become a comment"])
          expect { source_payment.reload }.to raise_error(ActiveRecord::RecordNotFound)
        end

        it "creates a payment dupe status" do
          source_donation = nonprofit.donations.create(amount: 100, supporter: supporter)
          source_donation.save!
          source_payment = source_donation.payments.create(nonprofit: nonprofit, kind: "OffsitePayment", date: Time.now, supporter: supporter, gross_amount: 100)
          source_payment.save!

          target_donation = nonprofit.donations.create(amount: 100, supporter: supporter)
          target_donation.save!
          target_payment = target_donation.payments.create(nonprofit: nonprofit, date: Time.now, kind: "Ticket", supporter: supporter, gross_amount: 100)
          target_payment.save!

          etap_import.e_tap_import_journal_entries.create(row: {"Account Number" => "123"})
          etap_import.e_tap_import_journal_entries.first.journal_entries_to_items.create(item: source_payment).save!

          described_class.remove_payment_dupes(nonprofit, ["A designation that should become a comment"])
          expect(target_payment.reload.payment_dupe_status.matched_with_offline).to eq([source_payment.id])
        end

        it "deletes the related activities" do
          donation = InsertDonation.offsite({:supporter_id => supporter.id, :nonprofit_id => nonprofit.id, "supporter_id" => supporter.id, "nonprofit_id" => nonprofit.id, "date" => Time.now.to_s, "amount" => 100})
          source_payment = Payment.find(donation[:json]["payment"]["id"])
          activity = Activity.where(attachment_id: source_payment.id, attachment_type: "Payment").first

          target_donation = nonprofit.donations.create(comment: "Some comment", amount: 100, supporter: supporter)
          target_donation.save!
          target_payment = target_donation.payments.create(nonprofit: nonprofit, date: Time.now, kind: "Ticket", supporter: supporter, gross_amount: 100)
          target_payment.save!

          etap_import.e_tap_import_journal_entries.create(row: {"Account Number" => "123"})
          etap_import.e_tap_import_journal_entries.first.journal_entries_to_items.create(item: source_payment).save!

          described_class.remove_payment_dupes(nonprofit, ["A designation that should become a comment"])
          expect { activity.reload }.to raise_error(ActiveRecord::RecordNotFound)
        end

        it "deletes the offsite_payment" do
          donation = InsertDonation.offsite({:supporter_id => supporter.id, :nonprofit_id => nonprofit.id, "supporter_id" => supporter.id, "nonprofit_id" => nonprofit.id, "date" => Time.now.to_s, "amount" => 100})
          source_payment = Payment.find(donation[:json]["payment"]["id"])
          offsite = source_payment.offsite_payment

          target_donation = nonprofit.donations.create(comment: "Some comment", amount: 100, supporter: supporter)
          target_donation.save!
          target_payment = target_donation.payments.create(nonprofit: nonprofit, date: Time.now, kind: "Ticket", supporter: supporter, gross_amount: 100)
          target_payment.save!

          etap_import.e_tap_import_journal_entries.create(row: {"Account Number" => "123"})
          etap_import.e_tap_import_journal_entries.first.journal_entries_to_items.create(item: source_payment).save!

          described_class.remove_payment_dupes(nonprofit, ["A designation that should become a comment"])
          expect { offsite.reload }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context "when the payment kind is a recurring donation" do
        it "deletes the offsite payment" do
          source_donation = nonprofit.donations.create(amount: 100, supporter: supporter)
          source_donation.save!
          source_donation_2 = nonprofit.donations.create(amount: 100, supporter: supporter)
          source_donation_2.save!
          source_donation_3 = nonprofit.donations.create(amount: 100, supporter: supporter)
          source_donation_3.save!

          source_payment = source_donation.payments.create(nonprofit: nonprofit, kind: "OffsitePayment", date: Time.now, supporter: supporter, gross_amount: 100)
          source_payment.save!
          source_payment_2 = source_donation_2.payments.create(nonprofit: nonprofit, date: Time.now - 2.days, kind: "OffsitePayment", supporter: supporter, gross_amount: 100)
          source_payment_2.save!
          source_payment_3 = source_donation_3.payments.create(nonprofit: nonprofit, date: Time.now - 5.days, kind: "OffsitePayment", supporter: supporter, gross_amount: 100)
          source_payment_3.save!

          target_donation = nonprofit.donations.create(amount: 100, supporter: supporter)
          target_donation.save!
          target_payment = target_donation.payments.create(nonprofit: nonprofit, date: Time.now, kind: "RecurringDonation", supporter: supporter, gross_amount: 100)
          target_payment.save!
          target_payment_2 = target_donation.payments.create(nonprofit: nonprofit, date: Time.now - 2.days, kind: "RecurringDonation", supporter: supporter, gross_amount: 100)
          target_payment_2.save!
          target_payment_3 = target_donation.payments.create(nonprofit: nonprofit, date: Time.now - 5.days, kind: "RecurringDonation", supporter: supporter, gross_amount: 100)
          target_payment_3.save!

          etap_import.e_tap_import_journal_entries.create(row: {"Account Number" => "123"})
          etap_import.e_tap_import_journal_entries.first.journal_entries_to_items.create(item: source_payment).save!

          etap_import.e_tap_import_journal_entries.create(row: {"Account Number" => "123"})
          etap_import.e_tap_import_journal_entries.first.journal_entries_to_items.create(item: source_payment_2).save!

          etap_import.e_tap_import_journal_entries.create(row: {"Account Number" => "123"})
          etap_import.e_tap_import_journal_entries.first.journal_entries_to_items.create(item: source_payment_3).save!

          described_class.remove_payment_dupes(nonprofit, ["A designation that should become a comment"])
          expect { source_payment.reload }.to raise_error(ActiveRecord::RecordNotFound)
          expect { source_payment_2.reload }.to raise_error(ActiveRecord::RecordNotFound)
          expect { source_payment_3.reload }.to raise_error(ActiveRecord::RecordNotFound)
        end

        it "deletes the offsite_payment" do
          donation = InsertDonation.offsite({:supporter_id => supporter.id, :nonprofit_id => nonprofit.id, "supporter_id" => supporter.id, "nonprofit_id" => nonprofit.id, "date" => Time.now.to_s, "amount" => 100})
          source_payment = Payment.find(donation[:json]["payment"]["id"])
          offsite = source_payment.offsite_payment

          donation_2 = InsertDonation.offsite({:supporter_id => supporter.id, :nonprofit_id => nonprofit.id, "supporter_id" => supporter.id, "nonprofit_id" => nonprofit.id, "date" => (Time.now - 2.days).to_s, "amount" => 100})
          source_payment_2 = Payment.find(donation_2[:json]["payment"]["id"])
          offsite_2 = source_payment_2.offsite_payment

          target_donation = nonprofit.donations.create(amount: 100, supporter: supporter)
          target_donation.payments.create(nonprofit: nonprofit, date: Time.now, kind: "RecurringDonation", supporter: supporter, gross_amount: 100)

          target_donation_2 = nonprofit.donations.create(amount: 100, supporter: supporter)
          target_donation_2.payments.create(nonprofit: nonprofit, date: Time.now - 2.days, kind: "RecurringDonation", supporter: supporter, gross_amount: 100)

          etap_import.e_tap_import_journal_entries.create(row: {"Account Number" => "123"})
          etap_import.e_tap_import_journal_entries.first.journal_entries_to_items.create(item: source_payment).save!

          etap_import.e_tap_import_journal_entries.create(row: {"Account Number" => "123"})
          etap_import.e_tap_import_journal_entries.first.journal_entries_to_items.create(item: source_payment_2).save!

          described_class.remove_payment_dupes(nonprofit, ["A designation that should become a comment"])
          expect { offsite.reload }.to raise_error(ActiveRecord::RecordNotFound)
          expect { offsite_2.reload }.to raise_error(ActiveRecord::RecordNotFound)
        end

        it "deletes the activities" do
          donation = InsertDonation.offsite({:supporter_id => supporter.id, :nonprofit_id => nonprofit.id, "supporter_id" => supporter.id, "nonprofit_id" => nonprofit.id, "date" => Time.now.to_s, "amount" => 100})
          source_payment = Payment.find(donation[:json]["payment"]["id"])
          activity = Activity.where(attachment_id: source_payment.id, attachment_type: "Payment").first

          donation_2 = InsertDonation.offsite({:supporter_id => supporter.id, :nonprofit_id => nonprofit.id, "supporter_id" => supporter.id, "nonprofit_id" => nonprofit.id, "date" => (Time.now - 2.days).to_s, "amount" => 100})
          source_payment_2 = Payment.find(donation_2[:json]["payment"]["id"])
          activity_2 = Activity.where(attachment_id: source_payment_2.id, attachment_type: "Payment").first

          target_donation = nonprofit.donations.create(amount: 100, supporter: supporter)
          target_donation.payments.create(nonprofit: nonprofit, date: Time.now, kind: "RecurringDonation", supporter: supporter, gross_amount: 100)

          target_donation_2 = nonprofit.donations.create(amount: 100, supporter: supporter)
          target_donation_2.payments.create(nonprofit: nonprofit, date: Time.now - 2.days, kind: "RecurringDonation", supporter: supporter, gross_amount: 100)

          etap_import.e_tap_import_journal_entries.create(row: {"Account Number" => "123"})
          etap_import.e_tap_import_journal_entries.first.journal_entries_to_items.create(item: source_payment).save!

          etap_import.e_tap_import_journal_entries.create(row: {"Account Number" => "123"})
          etap_import.e_tap_import_journal_entries.first.journal_entries_to_items.create(item: source_payment_2).save!

          described_class.remove_payment_dupes(nonprofit, ["A designation that should become a comment"])
          expect { activity.reload }.to raise_error(ActiveRecord::RecordNotFound)
          expect { activity_2.reload }.to raise_error(ActiveRecord::RecordNotFound)
        end

        it "creates a payment dupe status" do
          source_donation = nonprofit.donations.create(amount: 100, supporter: supporter)
          source_donation.save!
          source_payment = source_donation.payments.create(nonprofit: nonprofit, kind: "OffsitePayment", date: Time.now, supporter: supporter, gross_amount: 100)
          source_payment.save!
          source_payment_2 = source_donation.payments.create(nonprofit: nonprofit, date: Time.now - 2.days, kind: "OffsitePayment", supporter: supporter, gross_amount: 200)

          target_donation = nonprofit.donations.create(amount: 100, supporter: supporter)
          target_donation.save!
          target_payment = target_donation.payments.create(nonprofit: nonprofit, date: Time.now, kind: "RecurringDonation", supporter: supporter, gross_amount: 100)
          target_payment.save!
          target_payment_2 = target_donation.payments.create(nonprofit: nonprofit, date: Time.now - 2.days, kind: "RecurringDonation", supporter: supporter, gross_amount: 200)

          etap_import.e_tap_import_journal_entries.create(row: {"Account Number" => "123"})
          etap_import.e_tap_import_journal_entries.first.journal_entries_to_items.create(item: source_payment).save!

          etap_import.e_tap_import_journal_entries.create(row: {"Account Number" => "123"})
          etap_import.e_tap_import_journal_entries.first.journal_entries_to_items.create(item: source_payment_2).save!

          described_class.remove_payment_dupes(nonprofit, ["A designation that should become a comment"])
          expect(target_payment.reload.payment_dupe_status.matched_with_offline).to eq([source_payment.id])
          expect(target_payment_2.reload.payment_dupe_status.matched_with_offline).to eq([source_payment_2.id])
        end

        it "copies the dedication" do
          source_donation = nonprofit.donations.create(dedication: "Some dedication", amount: 100, supporter: supporter)
          source_donation.save!
          source_payment = source_donation.payments.create(nonprofit: nonprofit, kind: "OffsitePayment", date: Time.now, supporter: supporter, gross_amount: 100)
          source_payment.save!
          source_payment_2 = source_donation.payments.create(nonprofit: nonprofit, date: Time.now - 2.days, kind: "OffsitePayment", supporter: supporter, gross_amount: 200)

          target_donation = nonprofit.donations.create(amount: 100, supporter: supporter)
          target_donation.save!
          target_payment = target_donation.payments.create(nonprofit: nonprofit, date: Time.now, kind: "RecurringDonation", supporter: supporter, gross_amount: 100)
          target_payment.save!
          target_payment_2 = target_donation.payments.create(nonprofit: nonprofit, date: Time.now - 2.days, kind: "RecurringDonation", supporter: supporter, gross_amount: 200)

          etap_import.e_tap_import_journal_entries.create(row: {"Account Number" => "123"})
          etap_import.e_tap_import_journal_entries.first.journal_entries_to_items.create(item: source_payment).save!

          etap_import.e_tap_import_journal_entries.create(row: {"Account Number" => "123"})
          etap_import.e_tap_import_journal_entries.first.journal_entries_to_items.create(item: source_payment_2).save!

          described_class.remove_payment_dupes(nonprofit, ["A designation that should become a comment"])
          expect(target_payment.reload.donation.dedication).to eq("Some dedication")
          expect(target_payment_2.reload.donation.dedication).to eq("Some dedication")
        end

        it "copies the comment" do
          source_donation = nonprofit.donations.create(comment: "Some comment", amount: 100, supporter: supporter)
          source_donation.save!
          source_payment = source_donation.payments.create(nonprofit: nonprofit, kind: "OffsitePayment", date: Time.now, supporter: supporter, gross_amount: 100)
          source_payment.save!
          source_payment_2 = source_donation.payments.create(nonprofit: nonprofit, date: Time.now - 2.days, kind: "OffsitePayment", supporter: supporter, gross_amount: 200)

          target_donation = nonprofit.donations.create(amount: 100, supporter: supporter)
          target_donation.save!
          target_payment = target_donation.payments.create(nonprofit: nonprofit, date: Time.now, kind: "RecurringDonation", supporter: supporter, gross_amount: 100)
          target_payment.save!
          target_payment_2 = target_donation.payments.create(nonprofit: nonprofit, date: Time.now - 2.days, kind: "RecurringDonation", supporter: supporter, gross_amount: 200)

          etap_import.e_tap_import_journal_entries.create(row: {"Account Number" => "123"})
          etap_import.e_tap_import_journal_entries.first.journal_entries_to_items.create(item: source_payment).save!

          etap_import.e_tap_import_journal_entries.create(row: {"Account Number" => "123"})
          etap_import.e_tap_import_journal_entries.first.journal_entries_to_items.create(item: source_payment_2).save!

          described_class.remove_payment_dupes(nonprofit, ["A designation that should become a comment"])
          expect(target_payment.reload.donation.comment).to eq("Some comment")
          expect(target_payment_2.reload.donation.comment).to eq("Some comment")
        end

        it "copies the designation" do
          source_donation = nonprofit.donations.create(designation: "Some designation", amount: 100, supporter: supporter)
          source_donation.save!
          source_payment = source_donation.payments.create(nonprofit: nonprofit, kind: "OffsitePayment", date: Time.now, supporter: supporter, gross_amount: 100)
          source_payment.save!
          source_payment_2 = source_donation.payments.create(nonprofit: nonprofit, date: Time.now - 2.days, kind: "OffsitePayment", supporter: supporter, gross_amount: 200)

          target_donation = nonprofit.donations.create(amount: 100, supporter: supporter)
          target_donation.save!
          target_payment = target_donation.payments.create(nonprofit: nonprofit, date: Time.now, kind: "RecurringDonation", supporter: supporter, gross_amount: 100)
          target_payment.save!
          target_payment_2 = target_donation.payments.create(nonprofit: nonprofit, date: Time.now - 2.days, kind: "RecurringDonation", supporter: supporter, gross_amount: 200)

          etap_import.e_tap_import_journal_entries.create(row: {"Account Number" => "123"})
          etap_import.e_tap_import_journal_entries.first.journal_entries_to_items.create(item: source_payment).save!

          etap_import.e_tap_import_journal_entries.create(row: {"Account Number" => "123"})
          etap_import.e_tap_import_journal_entries.first.journal_entries_to_items.create(item: source_payment_2).save!

          described_class.remove_payment_dupes(nonprofit, ["A designation that should become a comment"])
          expect(target_payment.reload.donation.designation).to eq("Some designation")
          expect(target_payment_2.reload.donation.designation).to eq("Some designation")
        end

        context "when there are multiple offline matches for the same online payment" do
          it "doesnt delete the payments" do
            source_donation = nonprofit.donations.create(dedication: "Some dedication", amount: 100, supporter: supporter)
            source_donation.save!
            source_payment = source_donation.payments.create(nonprofit: nonprofit, kind: "OffsitePayment", date: Time.now, supporter: supporter, gross_amount: 100)
            source_payment.save!
            source_payment_2 = source_donation.payments.create(nonprofit: nonprofit, date: Time.now, kind: "OffsitePayment", supporter: supporter, gross_amount: 100)

            target_donation = nonprofit.donations.create(amount: 100, supporter: supporter)
            target_donation.save!
            target_donation.payments.create(nonprofit: nonprofit, date: Time.now, kind: "RecurringDonation", supporter: supporter, gross_amount: 100)

            etap_import.e_tap_import_journal_entries.create(row: {"Account Number" => "123"})
            etap_import.e_tap_import_journal_entries.first.journal_entries_to_items.create(item: source_payment).save!

            etap_import.e_tap_import_journal_entries.create(row: {"Account Number" => "123"})
            etap_import.e_tap_import_journal_entries.first.journal_entries_to_items.create(item: source_payment_2).save!

            expect { described_class.remove_payment_dupes(nonprofit, ["A designation that should become a comment"]) }.to change { Payment.all.count }.by(0)
          end
        end
      end
    end
  end
end
