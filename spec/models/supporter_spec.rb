# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

RSpec.describe Supporter, type: :model do
  it_behaves_like "an houidable entity", :supp
  it_behaves_like "a model with a calculated first and last name"

  it { is_expected.to have_many(:addresses).class_name("SupporterAddress") }
  it { is_expected.to belong_to(:primary_address).class_name("SupporterAddress") }
  it { is_expected.to have_many(:object_events) }

  describe "Supporter::Tags" do
    it { is_expected.to have_many(:tag_joins) }
    it { is_expected.to have_many(:tag_masters).through(:tag_joins) }
    it { is_expected.to have_many(:undeleted_tag_masters).through(:tag_joins).class_name("TagMaster").source("tag_master") }

    describe ".undeleted_tag_masters" do
      it "only contains undeleted tags masters" do
        nonprofit = create(:nonprofit_base)
        undeleted_tag_master = create(:tag_master_base, nonprofit: nonprofit)
        deleted_tag_master = create(:tag_master_base, nonprofit: nonprofit, deleted: true)
        supporter = create(:supporter_base, nonprofit: nonprofit, tag_joins: [build(:tag_join_base, tag_master: undeleted_tag_master), build(:tag_join_base, tag_master: deleted_tag_master)])

        expect(supporter.undeleted_tag_masters).to contain_exactly(undeleted_tag_master)
      end
    end
  end

  describe "Supporter::EmailLists" do
    it { is_expected.to have_many(:email_lists).through(:tag_masters) }
    it { is_expected.to have_many(:active_email_lists).through(:undeleted_tag_masters).source("email_list") }

    def prepare
      ActiveJob::Base.queue_adapter = :test
      ret = OpenStruct.new
      nonprofit = ret.nonprofit = create(:nonprofit_base)
      undeleted_tag_master = ret.undeleted_tag_master = create(:tag_master_base, nonprofit: nonprofit, email_list: build(:email_list_base, nonprofit: nonprofit))

      ret.undeleted_but_unassociated_tag_master = create(:tag_master_base, nonprofit: nonprofit, email_list: build(:email_list_base, nonprofit: nonprofit))
      deleted_tag_master = ret.deleted_tag_master = create(:tag_master_base, nonprofit: nonprofit, deleted: true, email_list: build(:email_list_base, nonprofit: nonprofit))
      ret.supporter = create(:supporter_base, nonprofit: nonprofit, tag_joins: [build(:tag_join_base, tag_master: undeleted_tag_master), build(:tag_join_base, tag_master: deleted_tag_master)])

      ActiveJob::Base.queue_adapter = :test # this is to clear any jobs that might have been created these objects
      ret
    end
    describe ".active_email_lists" do
      it "only contains an active email list tags masters" do
        ret = prepare
        expect(ret.supporter.active_email_lists).to contain_exactly(ret.undeleted_tag_master.email_list)
      end

      describe ".update_member_on_all_lists" do
        it "updates the correct lists" do
          ret = prepare

          supporter = ret.supporter
          supporter.active_email_lists.update_member_on_all_lists
          expect(MailchimpSignupJob).to have_been_enqueued.with(supporter, ret.undeleted_tag_master.email_list)

          expect(MailchimpSignupJob).to_not have_been_enqueued.with(supporter, ret.deleted_tag_master.email_list)
          expect(MailchimpSignupJob).to_not have_been_enqueued.with(supporter, ret.undeleted_but_unassociated_tag_master.email_list)
        end
      end
    end

    describe "update email lists on supporter save" do
      it "when name changed" do
        ret = prepare
        expect(ret.supporter).to receive(:update_member_on_all_lists)
        ret.supporter.update(name: "Another name")
      end

      it "when email changed" do
        ret = prepare
        expect(ret.supporter).to receive(:update_member_on_all_lists)
        ret.supporter.update(email: "another@email.address")
      end

      it "but not when phone number changes" do
        ret = prepare
        expect(ret.supporter).to_not receive(:update_member_on_all_lists)
        ret.supporter.update(phone: 920418918)
      end
    end

    context "after_save" do
      describe ".update_member_on_all_lists" do
        it "updates the correct lists on name change" do
          ret = prepare
          ret.supporter.update(name: "Another name")

          expect(MailchimpSignupJob).to have_been_enqueued.with(ret.supporter, ret.undeleted_tag_master.email_list)
        end

        it "updates nothing if something other than name and email change" do
          ret = prepare
          expect(MailchimpSignupJob).to_not have_been_enqueued
          ret.supporter.update(phone: "9305268998")

          expect(MailchimpSignupJob).to_not have_been_enqueued
        end
      end
    end
  end

  describe "#calculated_first_name" do
    it "has nil name" do
      supporter = build_stubbed(:supporter, name: nil)
      expect(supporter.calculated_first_name).to be_nil
    end

    it "has blank name" do
      supporter = build_stubbed(:supporter, name: "")
      expect(supporter.calculated_first_name).to be_nil
    end

    it "has one word name" do
      supporter = build_stubbed(:supporter, name: "Penelope")
      expect(supporter.calculated_first_name).to eq "Penelope"
    end

    it "has two word name" do
      supporter = build_stubbed(:supporter, name: "Penelope Schultz")
      expect(supporter.calculated_first_name).to eq "Penelope"
    end

    it "has three word name" do
      supporter = build_stubbed(:supporter, name: "Penelope Rebecca Schultz")
      expect(supporter.calculated_first_name).to eq "Penelope Rebecca"
    end
  end

  describe "#calculated_last_name" do
    it "has nil name" do
      supporter = build_stubbed(:supporter, name: nil)
      expect(supporter.calculated_last_name).to be_nil
    end

    it "has blank name" do
      supporter = build_stubbed(:supporter, name: "")
      expect(supporter.calculated_last_name).to be_nil
    end

    it "has one word name" do
      supporter = build_stubbed(:supporter, name: "Penelope")
      expect(supporter.calculated_last_name).to be_nil
    end

    it "has two word name" do
      supporter = build_stubbed(:supporter, name: "Penelope Schultz")
      expect(supporter.calculated_last_name).to eq "Schultz"
    end

    it "has three word name" do
      supporter = build_stubbed(:supporter, name: "Penelope Rebecca Schultz")
      expect(supporter.calculated_last_name).to eq "Schultz"
    end
  end

  describe "#cleanup_name" do
    it "keeps name when no first and last name" do
      s = Supporter.new(name: "Penelope")
      s.valid?
      expect(s.name).to eq "Penelope"
    end

    it "keeps copies first to name" do
      s = Supporter.new(name: "Penelope", first_name: "Eric")
      s.valid?
      expect(s.name).to eq "Eric"
    end

    it "copies last to name" do
      s = Supporter.new(name: "Penelope", first_name: "Eric", last_name: "Schultz")
      s.valid?
      expect(s.name).to eq "Eric Schultz"
    end

    it "copies first and last to name" do
      s = Supporter.new(first_name: "Eric", last_name: "Schultz")
      s.valid?
      expect(s.name).to eq "Eric Schultz"
    end
  end

  describe "#cleanup_address" do
    it "keeps address when no address_line2" do
      s = Supporter.new(address: "123 Main Street")
      s.valid?
      expect(s.address).to eq "123 Main Street"
    end

    it "copies no address_line2 when address is empty when" do
      s = Supporter.new
      s.valid?
      expect(s.address).to be_blank
    end

    it "combines address and address_line2 when both there" do
      s = Supporter.new(address: "123 Main Street", address_line2: "Suite 101")
      s.valid?
      expect(s.address).to eq "123 Main Street Suite 101"
    end

    it "replaces blank attributes with nil" do
      s = Supporter.new(address: "")
      s.valid?
      expect(s.address).to be_nil
    end
  end

  context "after_save" do
    describe "update_primary_address" do
      def have_one_address
        have_attributes(addresses: have_attributes(count: 1))
      end

      def have_saved_primary_address
        have_attributes(primary_address: be_present)
        have_attributes(primary_address: be_persisted)
      end

      def custom_address_attributes
        attributes_for(:supporter_with_fv_poverty, :with_custom_address_1).slice(:address, :state_code, :country, :zip_code, :city)
      end

      def empty_address_attributes
        attributes_for(:supporter_with_fv_poverty, :with_empty_address).slice(:address, :state_code, :country, :zip_code, :city)
      end

      context "when primary_address is originally nil" do
        context "and address is being created" do
          def create_supporter_and_update_supporter_address
            supporter = create(:supporter_with_fv_poverty)
            supporter.update_attributes(custom_address_attributes)
            supporter
          end

          it {
            supporter = create_supporter_and_update_supporter_address
            expect(supporter).to have_one_address
          }

          it {
            supporter = create_supporter_and_update_supporter_address
            expect(supporter).to have_saved_primary_address
          }

          it {
            supporter = create_supporter_and_update_supporter_address
            expect(supporter.primary_address).to have_attributes(custom_address_attributes)
          }

          context "and the address is being updated to nil attributes" do
            def empty_the_supporter_address(supporter)
              supporter.update(empty_address_attributes)
            end

            it "removes the primary address from the supporter" do
              supporter = create_supporter_and_update_supporter_address
              empty_the_supporter_address(supporter)
              expect(supporter.primary_address).to be_nil
            end

            it "deletes the empty primary address from the database" do
              supporter = create_supporter_and_update_supporter_address
              primary_address_id = supporter.primary_address.id
              empty_the_supporter_address(supporter)
              expect(SupporterAddress.where(id: primary_address_id)).to_not be_present
            end
          end
        end

        context "and the supporter being created has empty address fields" do
          it "does not create a primary address" do
            supporter = create(:supporter_with_fv_poverty, :with_blank_address)
            expect(supporter.primary_address).to be_nil
          end
        end
      end

      context "when primary_address originally exists" do
        def create_and_update_supporter_with_already_created_address
          supporter = create(:supporter_with_fv_poverty, :with_primary_address)
          supporter.update(custom_address_attributes)
          supporter
        end

        it {
          supporter = create_and_update_supporter_with_already_created_address
          expect(supporter).to have_one_address
        }

        it {
          supporter = create_and_update_supporter_with_already_created_address
          expect(supporter).to have_saved_primary_address
        }

        it "has new primary address" do
          supporter = create_and_update_supporter_with_already_created_address
          expect(supporter.primary_address).to have_attributes(custom_address_attributes)
        end
      end
    end
  end

  describe "#payments#during_np_year" do
    let(:nonprofit) { create(:nonprofit_base) }
    let(:supporter) { create(:supporter_base, nonprofit: nonprofit) }
    let(:payment1) { create(:payment_base, :with_offline_payment, supporter: supporter, nonprofit: nonprofit, date: Time.new.utc.beginning_of_year + 1.second) }
    let(:payment2) { create(:payment_base, :with_offline_payment, supporter: supporter, nonprofit: nonprofit, date: Time.new.utc.beginning_of_year + 7.hours) } # this is after midnight at Central Time
    let(:payment3) { create(:payment_base, :with_offline_payment, supporter: supporter, nonprofit: nonprofit, date: Time.new.utc.end_of_year + 1.second) } # this is before midnight at Central Time but after UTC

    before(:each) do
      payment1
      payment2
      payment3
    end

    it "has two payments when nonprofit has UTC time zone" do
      expect(supporter.payments.during_np_year(Time.new.utc.year)).to contain_exactly(payment1, payment2)
    end

    it "has 2 payments when nonprofit has Central time zone" do
      nonprofit.timezone = "America/Chicago"
      nonprofit.save!
      expect(supporter.payments.during_np_year(Time.new.utc.year)).to contain_exactly(payment2, payment3)
    end
  end
end
