# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'

describe Houdini::V1::Nonprofit, :type => :controller do
  describe :get do

  end

  describe :post do
    around {|e|
      @old_bp =Settings.default_bp
      e.run
      Settings.default_bp = @old_bp

    }
    def expect_validation_errors(actual, input)
      expected_errors = input.with_indifferent_access[:errors]
      expect(actual["errors"]).to match_array expected_errors
    end

    def create_errors(*wrapper_params)
      output = totally_empty_errors
      wrapper_params.each {|i| output[:errors].push(h(params: [i], messages: gr_e('presence')))}
      output
    end

    def h(h = {})
      h.with_indifferent_access
    end

    let(:totally_empty_errors) {
      {
        errors:
            [
                h(params: ["nonprofit[name]"], messages: gr_e("presence", "blank")),
                h(params: ["nonprofit[zip_code]"], messages: gr_e("presence", "blank")),
                h(params: ["nonprofit[state_code]"], messages: gr_e("presence", "blank")),
                h(params: ["nonprofit[city]"], messages: gr_e("presence", "blank")),

                h(params: ["user[name]"], messages: gr_e("presence", "blank")),
                h(params: ["user[email]"], messages: gr_e("presence", "blank")),
                h(params: ["user[password]"], messages: gr_e("presence", "blank")),
                h(params: ["user[password_confirmation]"], messages: gr_e("presence", "blank")),
            ]


      }.with_indifferent_access
    }
    describe 'authorization' do
      around {|e|
        Rails.configuration.action_controller.allow_forgery_protection = true
        e.run
        Rails.configuration.action_controller.allow_forgery_protection = false
      }
      it 'rejects csrf' do

        xhr :post, '/api/v1/nonprofit'
        expect(response.code).to eq "401"
      end
    end
    it 'validates nothing' do
      input = {}
      xhr :post, '/api/v1/nonprofit', input
      expect(response.code).to eq "400"
      expect_validation_errors(JSON.parse(response.body), create_errors("nonprofit", "user"))
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
      expected = create_errors("user")
      expected[:errors].push(h(params:["nonprofit[email]"], messages: gr_e("regexp")))
      #expected[:errors].push(h(params:["nonprofit[phone]"], messages: gr_e("regexp")))
      #expected[:errors].push(h(params:["nonprofit[url]"], messages: gr_e("regexp")))

      expect_validation_errors(JSON.parse(response.body), expected)
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
      expect(JSON.parse(response.body)['errors']).to include(h(params:["user[password]", "user[password_confirmation]"], messages: gr_e("is_equal_to")))

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

      expect_validation_errors(JSON.parse(response.body), {
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

      expect_validation_errors(JSON.parse(response.body), {
          errors: [
              h(
                  params:["user[email]"],
                  messages:["has already been taken"]
              )
          ]
      })


    end

    it "succeeds" do
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


def find_error_message(json, field_name)
  errors = json['errors']

  error = errors.select {|i| i["params"].any? {|j| j == field_name}}.first
  return error if !error
  return error["messages"]

end

def gr_e(*keys)
  keys.map {|i| I18n.translate("grape.errors.messages." + i, locale: 'en')}

end