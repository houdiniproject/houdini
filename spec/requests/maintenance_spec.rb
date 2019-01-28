# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'
require 'controllers/support/shared_user_context'

describe 'Maintenance Mode' do
  page = "http://commet"
  token = "thoathioa"
  include_context :shared_user_context
  around(:each) do |example|
    example.run
    Settings.reload!
  end

  describe OnboardController, type: :controller do
    describe '(Onboard is just a basic example controller)'
    it 'not in maintenance mode' do
      get :index
      assert_response 200
    end

    describe 'in maintenance' do
      before(:each) do
        Settings.merge!({maintenance:
                             {maintenance_mode: true,
                              maintenance_token: token,
                              maintenance_page: page}})
      end

      it 'redirects for onboard' do
        get :index
        assert_redirected_to page
      end

      it 'allows access to non-sign_in pages if youre logged in' do
        sign_in user_as_np_associate
        get :index
        assert_response 200
      end
    end
  end

  describe Users::SessionsController, type: :controller do
    describe 'in maintenance' do
      include_context :shared_user_context
      around(:each) do |example|
        example.run
        Settings.reload!
      end

      before(:each) do
        @request.env["devise.mapping"] = Devise.mappings[:user]
      end

      describe 'in maintenance' do
        before(:each) do
          Settings.merge!({maintenance:
                               {maintenance_mode: true,
                                maintenance_token: token,
                                maintenance_page: page}})
        end

        it 'redirects sign_in if the token is wrong' do
          get(:new, {maintenance_token: "#{token}3"})
          expect(response.code).to eq "302"
          expect(response.location).to eq page
        end

        it 'redirects for login' do
          get(:new)
          expect(response.code).to eq "302"
          expect(response.location).to eq page
        end


        it 'redirects sign_in if the token is passed in wrong param' do
          get(:new, {maintnancerwrwer_token: "#{token}"})
          expect(response.code).to eq "302"
          expect(response.location).to eq page
        end

        it 'allows sign_in if the token is passed' do
          get(:new, {maintenance_token: "#{token}"})
          expect(response.code).to eq '200'
        end

        it 'allows sign_in.json' do
          get(:new, {maintenance_token: "#{token}", format: 'json'})
          expect(response.code).to eq '200'
        end
      end
    end

    describe 'in maintenance without maintenance_token set' do
      before(:each) do
        @request.env["devise.mapping"] = Devise.mappings[:user]
      end
      before(:each) do
        Settings.merge!({maintenance:
                             {maintenance_mode: true,
                              maintenance_token: nil,
                              maintenance_page: page}})
      end

      it 'redirects sign_in if the token is nil' do
        get(:new)
        expect(response.code).to eq "302"
        expect(response.location).to eq page
      end
    end

  end
end

