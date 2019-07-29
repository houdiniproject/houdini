# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'
require 'api/support/api_shared_user_verification'
require 'support/api_errors'
include ExpectApi
describe Houdini::V1::Nonprofit, :type => :request do
  describe :get do

  end

  describe :post do
    around {|e|
      e.run
      Settings.reload!
    }



    let(:totally_empty_errors) {
      {
        errors:
            [
                h(params: ["nonprofit[name]"], messages: grape_error("presence", "blank")),
                h(params: ["nonprofit[zip_code]"], messages: grape_error("presence", "blank")),
                h(params: ["nonprofit[state_code]"], messages: grape_error("presence", "blank")),
                h(params: ["nonprofit[city]"], messages: grape_error("presence", "blank")),

                h(params: ["user[name]"], messages: grape_error("presence", "blank")),
                h(params: ["user[email]"], messages: grape_error("presence", "blank")),
                h(params: ["user[password]"], messages: grape_error("presence", "blank")),
                h(params: ["user[password_confirmation]"], messages: grape_error("presence", "blank")),
            ]


      }.with_indifferent_access
    }

    valid_input = {
        nonprofit: {name: "n", state_code: "WI", city: "appleton", zip_code: 54915, url: 'www.cs.c', website: 'www.cs.c'}.with_indifferent_access,
        user: {name: "Name", email: "em@em.com", password: "12345678", password_confirmation: "12345678"}.with_indifferent_access
    }

    describe 'authorization' do
      include_context :shared_donation_charge_context
      include_context :api_shared_user_verification
      describe 'csrf' do
        around {|e|
          Rails.configuration.action_controller.allow_forgery_protection = true
          e.run
          Rails.configuration.action_controller.allow_forgery_protection = false
        }
        it 'should rejects with a lack of csrf' do

          xhr :post, '/api/v1/nonprofit'
          expect(response.code).to eq "401"
        end
      end
    end
    it 'validates nothing' do
      input = {}
      xhr :post, '/api/v1/nonprofit', input
      expect(response.code).to eq "400"
      expect_api_validation_errors(JSON.parse(response.body), create_errors(totally_empty_errors, "nonprofit", "user"))
    end

    it 'validates url, email, phone ' do
      input = {
          nonprofit: {
              email: "noemeila",
              phone: "notphone",
              url: ""
          }}
      xhr :post, '/api/v1/nonprofit', input
      expect(response.code).to eq "400"
      expected = create_errors(totally_empty_errors,"user")
      expected[:errors].push(h(params:["nonprofit[email]"], messages: grape_error("regexp")))
      #expected[:errors].push(h(params:["nonprofit[phone]"], messages: gr_e("regexp")))
      #expected[:errors].push(h(params:["nonprofit[url]"], messages: gr_e("regexp")))

      expect_api_validation_errors(JSON.parse(response.body), expected)
    end

    it 'should reject unmatching passwords ' do
      input = {

          user: {
              email: "wmeil@email.com",
              name: "name",
              password: 'password',
              password_confirmation: 'doesn\'t match'
          }
      }
      xhr :post, '/api/v1/nonprofit', input
      expect(response.code).to eq "400"
      expect(JSON.parse(response.body)['errors']).to include(h(params:["user[password]", "user[password_confirmation]"], messages: grape_error(:is_equal_to)))

    end

    it 'attempts to make a slug copy and returns the proper errors' do
      force_create(:nonprofit, slug: "n", state_code_slug: "wi", city_slug: "appleton")
      input = {
          nonprofit: {name: "n", state_code: "WI", city: "appleton", zip_code: 54915},
          user: {name: "Name", email: "em@em.com", password: "12345678", password_confirmation: "12345678"}
      }

      expect_any_instance_of(SlugNonprofitNamingAlgorithm).to receive(:create_copy_name).and_raise(UnableToCreateNameCopyError.new)

      xhr :post, '/api/v1/nonprofit', input
      expect(response.code).to eq "400"

      expect_api_validation_errors(JSON.parse(response.body), {
          errors: [
              h(
                  params:["nonprofit[name]"],
                  messages:["has an invalid slug. Contact support for help."]
              )
          ]
      })
    end

    it 'errors on attempt to add user with email that already exists' do
      force_create(:user, email: 'em@em.com')

      input = {
          nonprofit: {name: "n", state_code: "WI", city: "appleton", zip_code: 54915},
          user: {name: "Name", email: "em@em.com", password: "12345678", password_confirmation: "12345678"}
      }

      xhr :post, '/api/v1/nonprofit', input
      expect(response.code).to eq "400"

      expect_api_validation_errors(JSON.parse(response.body), {
          errors: [
              h(
                  params:["user[email]"],
                  messages:["has already been taken"]
              )
          ]
      })


    end

    it "should succeed" do
      force_create(:nonprofit, slug: "n", state_code_slug: "wi", city_slug: "appleton")
      input = {
          nonprofit: {name: "n", state_code: "WI", city: "appleton", zip_code: 54915, url: 'www.cs.c', website: 'www.cs.c'},
          user: {name: "Name", email: "em@em.com", password: "12345678", password_confirmation: "12345678"}
      }

      bp = force_create(:billing_plan)
      Settings.default_bp.id = bp.id

      #expect(Houdini::V1::Nonprofit).to receive(:sign_in)

      xhr :post, '/api/v1/nonprofit', input
      expect(response.code).to eq "201"

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


    end


  end
end



