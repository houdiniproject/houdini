# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

RSpec.describe RegisterNonprofitForm::NonprofitForm, type: :model do
  describe "#website" do
    it { is_expected.to allow_value("www.exa.cs").for(:website) }

    it "normalizes with http" do
      form = described_class.new(website: "www.exa.cs")

      expect(form.website).to eq "http://www.exa.cs"
    end
  end

  it "validates email" do
    form = described_class.new({
      email: "noemeila",
      phone: "notphone",
      website: ""
    })
    form.valid?

    # we should have the email validation from User model
    expect(form.errors.messages_for(:email)).to be_one
  end

  describe "slug management" do
    let(:nonprofit_attributes) do
      attributes_for(
        :nonprofit_base,
        slug: nil,
        zip_code: 51455
      ).slice(
        :name,
        :city,
        :email,
        :state_code,
        :phone,
        :website,
        :zip_code
      )
    end

    it "creates slug when easy" do
      form = described_class.new(nonprofit_attributes) # nil so it autocreates the slug

      expect(form).to be_valid
      expect(form.nonprofit.slug).to eq "ending-poverty-in-the-fox-valley-inc"
    end

    it "generates a new slug when the slug is already taken" do
      create(:nonprofit_base, slug: nil) # so the slug is already taken

      form = described_class.new(nonprofit_attributes) # nil so it autocreates the slug

      expect(form).to be_valid
      expect(form.nonprofit.slug).to eq "ending-poverty-in-the-fox-valley-inc-00"
    end

    it "fails at creating a new slug" do
      allow_any_instance_of(SlugNonprofitNamingAlgorithm)
        .to receive(:create_copy_name)
        .and_raise(UnableToCreateNameCopyError.new)

      force_create(:nonprofit, slug: "n", state_code_slug: "wi", city_slug: "appleton")
      form = described_class.new({name: "n", state_code: "WI", city: "appleton", zip_code: 54915}) # nil so it autocreates the slug

      expect(form).not_to be_valid

      errors = form.errors.to_hash

      expect(errors).to eq({name: ["has an invalid slug. Contact support for help."]})
    end
  end
end
