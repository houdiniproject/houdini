# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"
require "controllers/support/shared_user_context"

describe EmailSettingsController, type: :controller do
  describe "authorization" do
    include_context :shared_user_context
    describe "rejects unauthorized users" do
      describe "create" do
        include_context :open_to_np_associate, :post, :create, nonprofit_id: :__our_np
      end

      describe "index" do
        include_context :open_to_np_associate, :get, :index, nonprofit_id: :__our_np
      end
    end
  end

  describe "#create" do
    let(:params) do
      {
        nonprofit_id: nonprofit.id,
        email_settings: {
          notify_campaigns: "false",
          notify_events: "true",
          notify_payments: "true",
          notify_payouts: "false",
          notify_recurring_donations: "true"
        }
      }
    end

    let(:params_with_user) do
      params.merge(user_id: nonprofit_admin.id)
    end

    let(:expected_email_settings_attribs) {
      {
        notify_campaigns: false,
        notify_events: true,
        notify_payments: true,
        notify_payouts: false,
        notify_recurring_donations: true,
        user_id: nonprofit_admin.id,
        nonprofit_id: nonprofit.id
      }.stringify_keys
    }

    let(:nonprofit) { create(:nonprofit_base) }
    let(:nonprofit_admin) { create(:user_as_nonprofit_admin, nonprofit: nonprofit) }
    let(:super_admin) { create(:user_as_super_admin) }

    let(:email_setting_for_nonprofit_admin) { create(:email_setting, nonprofit: nonprofit, user: nonprofit_admin) }

    describe "when no email setting exists" do
      describe "for non-superadmin" do
        before do
          sign_in nonprofit_admin
        end

        it "creates a new email setting" do
          expect do
            post :create, params: params
          end.to change { EmailSetting.count }.by(1)

          expect(response).to have_http_status(:success)
          expect(EmailSetting.last).to have_attributes(expected_email_settings_attribs)

          expect(JSON.parse(response.body)).to include(expected_email_settings_attribs)
        end
      end

      describe "for superadmin" do
        before do
          sign_in super_admin
        end

        it "creates a new email setting" do
          expect do
            post :create, params: params_with_user
          end.to change { EmailSetting.count }.by(1)

          expect(response).to have_http_status(:success)
          expect(EmailSetting.last).to have_attributes(expected_email_settings_attribs)

          expect(JSON.parse(response.body)).to include(expected_email_settings_attribs)
        end
      end
    end

    describe "when email setting already exists" do
      before do
        email_setting_for_nonprofit_admin
      end

      describe "for non-superadmin" do
        before do
          sign_in nonprofit_admin
        end

        it "updates email setting" do
          expect do
            post :create, params: params
          end.to_not change { EmailSetting.count }

          expect(response).to have_http_status(:success)
          expect(EmailSetting.last).to have_attributes(expected_email_settings_attribs)

          expect(JSON.parse(response.body)).to include(expected_email_settings_attribs)
        end
      end

      describe "for superadmin" do
        before do
          sign_in super_admin
        end

        it "update the new email setting" do
          expect do
            post :create, params: params_with_user
          end.to_not change { EmailSetting.count }

          expect(response).to have_http_status(:success)
          expect(EmailSetting.last).to have_attributes(expected_email_settings_attribs)

          expect(JSON.parse(response.body)).to include(expected_email_settings_attribs)
        end
      end
    end
  end
end
