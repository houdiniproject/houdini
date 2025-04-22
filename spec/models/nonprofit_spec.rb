# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"

RSpec.describe Nonprofit, type: :model do
  describe ".currency_symbol" do
    let(:nonprofit) { force_create(:nm_justice, currency: "eur") }
    let(:euro) { "€" }

    it "finds correct currency symbol for nonprofit" do
      expect(nonprofit.currency_symbol).to eq euro
    end
  end

  describe ".for_type" do
    let(:nonprofit) { create(:nm_justice) }
    let(:type) { "supporter.created" }
    let(:other_type) { "supporter.deleted" }
    let!(:object_event_hook_config) do
      nonprofit.object_event_hook_configs.create(
        webhook_service: :open_fn,
        configuration:
          {
            webhook_url: "https://www.openfn.org/inbox/my-inbox-id",
            headers: {"x-api-key": "my-secret-key"}
          },
        object_event_types: [type, other_type]
      )
    end

    describe "there is an ObjectEventHookConfig for the specified type" do
      it "returns a list of ObjectEventHookConfigs" do
        result = nonprofit.object_event_hook_configs.for_type(type)
        expect(result).to eq([object_event_hook_config])
      end
    end

    describe "there is not an ObjectEventHookConfig for the specified type" do
      let(:some_other_type) { "supporter.updated" }

      it "returns an empty list" do
        result = nonprofit.object_event_hook_configs.for_type(some_other_type)
        expect(result).to eq([])
      end
    end
  end

  describe "create" do
    describe "validates on parameters" do
      let(:nonprofit) { Nonprofit.new }
      let(:nonprofit_with_invalid_user) { Nonprofit.new(user_id: 3333) }
      let(:nonprofit_with_user_who_already_admin) {
        nonprofit_admin_role
        Nonprofit.new(user_id: user.id)
      }

      let(:nonprofit_with_same_name) { Nonprofit.new({name: "New Mexico Equality", state_code: nm_justice.state_code, city: nm_justice.city, user_id: user.id}) }
      let(:nonprofit_with_same_name_but_different_state) { Nonprofit.new({name: "New Mexico Equality", state_code: "mn", city: nm_justice.city, user_id: user.id}) }

      let(:nonprofit_with_bad_email_and_website) { Nonprofit.new({email: "not_email", website: "not_website"}) }

      let(:nonprofit_with_not_US_state) { Nonprofit.new(user_id: user.id, state_code: "KK") }
      let(:nonprofit_with_non_capitalized_state_code) { Nonprofit.new(user_id: user.id, state_code: "Or") }

      let(:user) { create(:user) }
      let(:nonprofit_admin_role) do
        role = user.roles.build(host: nonprofit, name: "nonprofit_admin")
        role.save!
        role
      end
      let(:nm_justice) { create(:nm_justice) }

      before do
        nonprofit.valid?
        nonprofit_with_invalid_user.valid?
        nonprofit_with_user_who_already_admin.valid?
        nonprofit_with_same_name.valid?
        nonprofit_with_same_name_but_different_state.valid?
        nonprofit_with_bad_email_and_website.valid?
        nonprofit_with_not_US_state.valid?
        nonprofit_with_non_capitalized_state_code.valid?
      end

      it "has an error for no name" do
        expect(nonprofit.errors["name"].first).to match(/.*blank.*/)
      end

      it "has an error for no user" do
        expect(nonprofit.errors["user_id"].first).to match(/.*blank.*/)
      end

      it "has an error for no city" do
        expect(nonprofit.errors["city"].first).to match(/.*blank.*/)
      end

      it "has an error for no state" do
        expect(nonprofit.errors["state_code"].first).to match(/.*blank.*/)
      end

      it "has an error for not in the US state" do
        expect(nonprofit_with_not_US_state.errors["state_code"]).to match_array ["must be a US two-letter state code"]
      end

      it "does nothing when the state code is not capitalized" do
        expect(nonprofit_with_non_capitalized_state_code.errors["state_code"]).to be_empty
      end

      it "rejects an invalid user" do
        expect(nonprofit_with_invalid_user.errors["user_id"].first).to match(/.*not a valid user.*/)
      end

      it "rejects a user who is already an admin" do
        expect(nonprofit_with_user_who_already_admin.errors["user_id"].first).to match(/.*admin.*/)
      end

      it "accepts and corrects a slug when it tries to save" do
        expect(nonprofit_with_same_name.errors["slug"]).to be_empty
        expect(nonprofit_with_same_name.slug).to eq "#{nm_justice.slug}-00"
      end

      it "does nothing to a slug when a slug was provided" do
        expect(nonprofit_with_same_name_but_different_state.errors["slug"]).to be_empty
        expect(nonprofit_with_same_name_but_different_state.slug).to eq "#{nm_justice.slug}"
      end

      it "marks email as having errors if they do" do
        expect(nonprofit_with_bad_email_and_website.errors["email"].first).to match(/.*invalid.*/)
      end

      describe "website validation" do
        it "marks as having errors if it does not have a public suffix" do
          expect(nonprofit_with_bad_email_and_website.errors["website"].first)
            .to match("is not a valid URL")
        end

        it "does not mark website as having errors if it does not have a scheme and adds scheme" do
          nonprofit_with_bad_email_and_website.update(website: "a_website.com")
          expect(nonprofit_with_bad_email_and_website.errors["website"].first)
            .to be_nil
          expect(nonprofit_with_bad_email_and_website.website)
            .to eq("http://a_website.com")
        end

        it "marks as having errors if a non-accpted scheme is provided" do
          nonprofit_with_bad_email_and_website.update(website: "ftp://invalid.com")
          expect(nonprofit_with_bad_email_and_website.errors["website"].first)
            .to match("is not a valid URL")
          expect(nonprofit_with_bad_email_and_website.website)
            .to eq("ftp://invalid.com")
        end

        it "marks as having errors if an array is provided" do
          nonprofit_with_bad_email_and_website.update(website: [])
          expect(nonprofit_with_bad_email_and_website.errors["website"].first)
            .to match("is not a valid URL")
          expect(nonprofit_with_bad_email_and_website.website)
            .to eq("[]")
        end

        it "marks as having errors if there is a space in the website string" do
          nonprofit_with_bad_email_and_website.update(website: "invalid .com")
          expect(nonprofit_with_bad_email_and_website.errors["website"].first)
            .to match("is not a valid URL")
          expect(nonprofit_with_bad_email_and_website.website)
            .to eq("invalid .com")
        end

        it "marks as having errors if a number is provided" do
          nonprofit_with_bad_email_and_website.update(website: 1234)
          expect(nonprofit_with_bad_email_and_website.errors["website"].first)
            .to match("is not a valid URL")
          expect(nonprofit_with_bad_email_and_website.website)
            .to eq("1234")
        end

        it "marks as having errors if a hash is provided" do
          nonprofit_with_bad_email_and_website.update(website: {})
          expect(nonprofit_with_bad_email_and_website.errors["website"].first)
            .to match("is not a valid URL")
          expect(nonprofit_with_bad_email_and_website.website)
            .to eq("{}")
        end
      end

      it "marks an nonprofit as invalid when no slug could be created " do
        nonprofit = Nonprofit.new({name: nm_justice.name, city: nm_justice.city, state_code: nm_justice.state_code, slug: nm_justice.slug})
        expect_any_instance_of(SlugNonprofitNamingAlgorithm).to receive(:create_copy_name).and_raise(UnableToCreateNameCopyError.new)
        nonprofit.valid?
        expect(nonprofit.errors["slug"].first).to match(/.*could not be created.*/)
      end

      describe "timezone validations" do
        it "does not fail if the timezone is nil" do
          expect { create(:nm_justice, timezone: nil) }.not_to raise_error(ActiveRecord::RecordInvalid)
        end

        it "does not fail if the timezone is readable by postgres" do
          expect { create(:nm_justice, timezone: "America/Chicago") }.not_to raise_error(ActiveRecord::RecordInvalid)
        end

        it "raises error if the timezone is invalid" do
          expect { create(:nm_justice, timezone: "Central Time (US & Canada)") }.to raise_error(ActiveRecord::RecordInvalid)
        end
      end
    end
  end
end
