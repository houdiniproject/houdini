# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

RSpec.describe NonprofitSettingsForm do
  let(:nonprofit) { create(:nonprofit_base, require_two_factor: false) }
  let(:form) { described_class.new(nonprofit: nonprofit, attributes: attributes) }

  describe "#save" do
    context "when updating general attributes" do
      let(:attributes) { {"name" => "New Organization Name"} }

      it "updates the nonprofit" do
        expect { form.save }.to change { nonprofit.reload.name }.to("New Organization Name")
      end

      it "returns true" do
        expect(form.save).to be true
      end
    end

    context "when enabling two-factor authentication" do
      let(:attributes) { {"require_two_factor" => true} }

      let!(:user_with_2fa) do
        create(:user_as_nonprofit_admin,
          nonprofit: nonprofit,
          otp_required_for_login: true)
      end

      let!(:user_without_2fa) do
        create(:user_as_nonprofit_associate,
          nonprofit: nonprofit,
          otp_required_for_login: false)
      end

      before do
        allow(User).to receive(:generate_otp_secret).and_return("SECRET123")
      end

      it "enables two-factor for the nonprofit" do
        expect { form.save }.to change { nonprofit.reload.require_two_factor? }.from(false).to(true)
      end

      it "enables two-factor for users without it" do
        expect { form.save }.to change { user_without_2fa.reload.otp_required_for_login }.from(false).to(true)
      end

      it "generates OTP secrets for users without two-factor" do
        form.save
        expect(user_without_2fa.reload.otp_secret).to eq("SECRET123")
      end

      it "does not modify users who already have two-factor" do
        expect { form.save }.not_to change { user_with_2fa.reload.otp_secret }
      end
    end

    context "when disabling two-factor authentication" do
      let(:nonprofit) { create(:nonprofit_base, require_two_factor: true) }
      let(:attributes) { {"require_two_factor" => false} }
      let!(:user) { create(:user_as_nonprofit_admin, nonprofit: nonprofit, otp_required_for_login: true) }

      it "disables the requirement for the nonprofit" do
        expect { form.save }.to change { nonprofit.reload.require_two_factor? }.from(true).to(false)
      end

      it "does not modify existing user settings" do
        expect { form.save }.not_to change { user.reload.otp_required_for_login }
      end
    end

    context "when two-factor is already enabled" do
      let(:nonprofit) { create(:nonprofit_base, require_two_factor: true) }
      let(:attributes) { {"require_two_factor" => true} }
      let!(:user) { create(:user_as_nonprofit_associate, nonprofit: nonprofit, otp_required_for_login: false) }

      it "does not enforce two-factor on users" do
        expect { form.save }.not_to change { user.reload.otp_required_for_login }
      end
    end

    context "with invalid data" do
      let(:attributes) { {"name" => ""} }

      before do
        allow(nonprofit).to receive(:update!).and_raise(
          ActiveRecord::RecordInvalid.new(nonprofit)
        )
      end

      it "returns false" do
        expect(form.save).to be false
      end

      it "adds errors" do
        form.save
        expect(form.errors[:base]).to be_present
      end
    end

    context "when transaction rollback is needed" do
      let(:attributes) { {"require_two_factor" => true} }
      let!(:user) { create(:user_as_nonprofit_admin, nonprofit: nonprofit, otp_required_for_login: false) }

      before do
        allow(form).to receive(:enforce_two_factor_for_all_users).and_raise(ActiveRecord::RecordInvalid.new(user))
      end

      it "rolls back the nonprofit change" do
        expect { form.save }.not_to change { nonprofit.reload.require_two_factor? }
      end

      it "returns false" do
        expect(form.save).to be false
      end
    end
  end
end
