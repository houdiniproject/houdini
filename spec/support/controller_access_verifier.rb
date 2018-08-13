require 'rails_helper'
require 'support/access_verifier'
module ControllerAccessVerifier
  def create_verifier(*)
    InnerControllerAccessVerifier.new

  end

  class InnerControllerAccessVerifier < AccessVerifier
    def initialize(*)
      let(:nonprofit) {
        args[:nonprofit] || force_create(:nonprofit, published:true)
      }
    end
    def send(method, *args)
      case method
      when :get
        return get(*args)
      when :post
        return post(*args)
      when :delete
        return delete(*args)
      when :put
        return put(*args)
      end
    end

    def accept(user_to_signin, method, action, *args)
      sign_in user_to_signin if user_to_signin
      # allows us to run the helpers but ignore what the controller action does
      #
      expect_any_instance_of(described_class).to receive(action).and_return(ActionController::TestResponse.new(200))
      expect_any_instance_of(described_class).to receive(:render).and_return(nil)
      send(method, action, *args)
      expect(response.status).to eq 200
    end

    def reject(user_to_signin, method, action, *args)
      sign_in user_to_signin if user_to_signin
      send(method, action, *args)
      expect(response.status).to eq 302
    end


  end
end