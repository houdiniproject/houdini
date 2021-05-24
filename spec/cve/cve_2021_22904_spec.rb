# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
# from rails
require 'rails_helper'

describe 'CVE Test 2021-22904', type: :controller do 

  controller(ActionController::Base) do 
      before_action :authenticate, only: :index
      before_action :authenticate_with_request, only: :display
      before_action :authenticate_long_credentials, only: :show
  
      def index
        render plain: "Hello Secret"
      end
  
      def display
        render plain: "Definitely Maybe"
      end
  
      def show
        render plain: "Only for loooooong credentials"
      end
  
      private
        def authenticate
          authenticate_or_request_with_http_token do |token, _|
            token == "lifo"
          end
        end
  
        def authenticate_with_request
          if authenticate_with_http_token { |token, options| token == '"quote" pretty' && options[:algorithm] == "test" }
            @logged_in = true
          else
            request_http_token_authentication("SuperSecret", "Authentication Failed\n")
          end
        end
  
        def authenticate_long_credentials
          authenticate_or_request_with_http_token do |token, options|
            token == "1234567890123456789012345678901234567890" && options[:algorithm] == "test"
          end
        end
  end

  it "handles evil token" do
    @request.env["HTTP_AUTHORIZATION"] = "Token ." + " " * (1024*80-8) + "."
    Timeout.timeout(1) do
      get :index
    end
    
    assert_response :unauthorized
    assert_equal "HTTP Token: Access denied.\n", @response.body, "Authentication header was not properly parsed"
  end
  
end