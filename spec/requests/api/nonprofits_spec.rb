# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'

describe Api::NonprofitsController, :type => :request do

  describe 'post' do
    around {|e|
      @old_bp =Settings.default_bp
      bp = force_create(:billing_plan)
      Settings.default_bp.id = bp.id
      e.run
      Settings.default_bp = @old_bp

    }
    def expect_validation_errors(actual, input)
      expected_errors = input.with_indifferent_access[:errors]
      expect(actual["errors"]).to match_array expected_errors
    end

    def create_errors(*wrapper_params)
      output = totally_empty_errors
      output
    end

    let(:totally_empty_errors) {
      {
        errors:
            {
                "nonprofit[name]" => ["can't be blank"],
                "nonprofit[zip_code]" => ["can't be blank"],
                "nonprofit[state_code]" => ["can't be blank"],
                "nonprofit[city]" => ["can't be blank"],
                "nonprofit[slug]" => ["can't be blank"],

                "user[name]" => ["can't be blank"],
                "user[email]" => ["can't be blank", "is invalid"],
                "user[password]" => ["can't be blank"],
                "user[password_confirmation]" => ["can't be blank"],
            }


      }.with_indifferent_access
    }

    let(:valid_nonprofit_attribs) {
      {name: "n", state_code: "WI", city: "appleton", zip_code: 54915}
    }
    it 'validates nothing' do
      input = {}
      post '/api/nonprofits', params: input, xhr: true
      expect(response.code).to eq "400"
      expect_validation_errors(JSON.parse(response.body), create_errors("nonprofit", "user"))
    end

    it 'validates url, email, phone ' do
      input = {
          nonprofit: {
              email: "noemeila",
              phone: "notphone",
              website: ""
          }}
      post '/api/nonprofits', params: input, xhr: true
      expect(response.code).to eq "400"
      expected = create_errors("user")
      expected[:errors]["nonprofit[email]"] = ["is invalid"]
      expect_validation_errors(JSON.parse(response.body), expected)
    end

    it 'should reject unmatching passwords ' do
      input = {
          nonprofit: valid_nonprofit_attribs,
          user: {
              email: "wmeil@email.com",
              name: "name",
              password: 'password',
              password_confirmation: 'doesn\'t match'
          }
      }
      post '/api/nonprofits', params: input, xhr: true
      expect(response.code).to eq "400"
      expect(JSON.parse(response.body)['errors']).to include("user[password_confirmation]" => ["doesn't match Password"])

    end

    it 'attempts to make a slug copy and returns the proper errors' do
      force_create(:nonprofit, slug: "n", state_code_slug: "wi", city_slug: "appleton")
      input = {
          nonprofit: {name: "n", state_code: "WI", city: "appleton", zip_code: 54915},
          user: {name: "Name", email: "em@em.com", password: "12345678", password_confirmation: "12345678"}
      }

      expect_any_instance_of(SlugNonprofitNamingAlgorithm).to receive(:create_copy_name).and_raise(UnableToCreateNameCopyError.new)

      post '/api/nonprofits', params:input, xhr: true
      expect(response.code).to eq "400"

      expect_validation_errors(JSON.parse(response.body), {
          errors: [
            ["nonprofit[name]", ["has an invalid slug. Contact support for help."]],
          ]
      })
    end

    it 'errors on attempt to add user with email that already exists' do
      force_create(:user, email: 'em@em.com')

      input = {
          nonprofit: {name: "n", state_code: "WI", city: "appleton", zip_code: 54915},
          user: {name: "Name", email: "em@em.com", password: "12345678", password_confirmation: "12345678"}
      }

      post '/api/nonprofits', params: input, xhr: true
      expect(response.code).to eq "400"

      expect_validation_errors(JSON.parse(response.body), {
          errors: [
            ["user[email]", ["has already been taken"]],
          ]
      })


    end

    it "succeeds" do

      ActiveJob::Base.queue_adapter = :test
      StripeMockHelper.start      
      create(:nonprofit_base, name:"not-something", slug: "n", state_code_slug: "wi", city_slug: "appleton")

      input = {
          nonprofit: {name: "n", state_code: "WI", city: "appleton", zip_code: 54915, url: 'www.cs.c', website: 'www.cs.c'},
          user: {name: "Name", email: "em@em.com", password: "12345678", password_confirmation: "12345678"}
      }

      bp = force_create(:billing_plan)
      Settings.default_bp.id = bp.id

      post '/api/nonprofits', params: input, xhr: true

      expect(response.code).to eq "201"
      expect(MailchimpNonprofitUserAddJob).to have_been_enqueued

      our_np = Nonprofit.all[1]
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

      response_body = {
          id: our_np.id
      }.with_indifferent_access

      expect(JSON.parse(response.body)).to eq response_body

      user = User.first
      expected_user = {
          email: "em@em.com",
          name: "Name"
      }

      expected_user = user.attributes.with_indifferent_access.merge(expected_user)
      expect(our_np.roles.nonprofit_admins.count).to eq 1
      expect(our_np.roles.nonprofit_admins.first.user.attributes).to eq expected_user

      StripeMockHelper.stop
    end
  end
end
