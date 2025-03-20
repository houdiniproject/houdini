# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

RSpec.describe RegisterNonprofitForm, :type => :model do

  around do |e|
    StripeMockHelper.mock do
      old_bp =Settings.default_bp
      
      
      
      Settings.default_bp.id = bp.id
      
      e.run
     
      Settings.default_bp = old_bp
    end
  end

  let(:bp) { force_create(:billing_plan) }

  it 'validates email' do
    input = {
      nonprofit_attributes: {
          email: "noemeila",
          phone: "notphone",
          website: ""
      }
    }

    form = RegisterNonprofitForm.new(input)

    expect(form.save).to eq false

    expect(form.errors.of_kind?("nonprofit[email]", :invalid)).to be true
end

  it 'should reject unmatching passwords ' do
    input = {
        nonprofit_attributes: {},
        user_attributes: {
            email: "wmeil@email.com",
            name: "name",
            password: 'password',
            password_confirmation: 'doesn\'t match'
        }
    }
    form = RegisterNonprofitForm.new(input)

    expect(form.save).to eq false
    errors = form.errors.to_hash
    expect(form.errors.of_kind?("user[password_confirmation]", "doesn't match Password")).to be true
  end

  it 'attempts to make a slug copy and returns the proper errors' do
    force_create(:nonprofit, slug: "n", state_code_slug: "wi", city_slug: "appleton")
    input = {
        nonprofit_attributes: {name: "n", state_code: "WI", city: "appleton", zip_code: 54915},
        user_attributes: {name: "Name", email: "em@em.com", password: "12345678", password_confirmation: "12345678"}
    }

    expect_any_instance_of(SlugNonprofitNamingAlgorithm).to receive(:create_copy_name).and_raise(UnableToCreateNameCopyError.new)

    form = RegisterNonprofitForm.new(input)

    expect(form.save).to eq false
    errors = form.errors.to_hash
    
    expect(errors).to eq "nonprofit[name]": ["has an invalid slug. Contact support for help."]
  end

  it 'errors on attempt to add user with email that already exists' do
    force_create(:user, email: 'em@em.com')

    input = {
        nonprofit_attributes: {name: "n", state_code: "WI", city: "appleton", zip_code: 54915},
        user_attributes: {name: "Name", email: "em@em.com", password: "12345678", password_confirmation: "12345678"}
    }

    form = RegisterNonprofitForm.new(input)

    expect(form.save).to eq false

    errors = form.errors.to_hash


    expect(errors).to eq "user[email]": ["has already been taken"]
  end

  it 'validate rollback' do

    ActiveJob::Base.queue_adapter = :test 
    input = {
      nonprofit_attributes: {name: "n", state_code: "WI", city: "appleton", zip_code: 54915, website: 'www.cs.c'},
      user_attributes: {name: "Name", email: "em@em.com", password: "12345678", password_confirmation: "12345678"}
    }


    form = RegisterNonprofitForm.new(input)

    expect(form.stripe_account_form).to receive(:save!).and_raise(ActiveRecord::RecordNotSaved) # we just need one of the catchable errors

    form.save

    expect(form.nonprofit).to_not be_persisted
    expect(form.user).to_not be_persisted
    
  end

  it "succeeds" do

    ActiveJob::Base.queue_adapter = :test 
    create(:nonprofit_base, name:"not-something", slug: "n", state_code_slug: "wi", city_slug: "appleton")

    input = {
        nonprofit_attributes: {name: "n", state_code: "WI", city: "appleton", zip_code: 54915, website: 'www.cs.c'},
        user_attributes: {name: "Name", email: "em@em.com", password: "12345678", password_confirmation: "12345678"}
    }


    form = RegisterNonprofitForm.new(input)

    result = form.save
    expect(result).to be true

    expect(MailchimpNonprofitUserAddJob).to have_been_enqueued

    our_np = form.nonprofit
    expected_np = {
        name: "n",
        state_code: "WI",
        city: "appleton",
        zip_code: "54915",
        state_code_slug: "wi",
        city_slug: "appleton",
        slug: "n-00",
        website: 'http://www.cs.c'
    }.with_indifferent_access

    expected_np = our_np.attributes.with_indifferent_access.merge(expected_np)
    expect(our_np.attributes).to eq expected_np

    expect(our_np.billing_subscription.billing_plan).to eq bp

    expect(our_np.stripe_account_id).to_not be_nil

    expect(form.id).to eq our_np.id

    user = form.user

    expect(our_np.roles.nonprofit_admins.map(&:user)).to match_array user
  end
end