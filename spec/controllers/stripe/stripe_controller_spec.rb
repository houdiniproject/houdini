require "rails_helper"

RSpec.describe Webhooks::StripeController, type: :controller do
  describe "POST #receive" do
    describe "verification of input" do
      it "returns on bad json" do
        expect(JSON).to receive(:parse).and_raise(JSON::ParserError)
        post :receive
        expect(response.body).to include("Invalid payload")
        expect(response.status).to eq 400
      end

      it "returns on bad signature" do
        post :receive, body: {}.to_json
        expect(response.body).to include("Invalid signature")
        expect(response.status).to eq 400
      end

      it "returns on other error" do
        expect(JSON).to receive(:parse).and_raise(ArgumentError)
        request.headers["HTTP_STRIPE_SIGNATURE"] = ""
        post :receive, body: {}.to_json
        expect(response.body).to include("Unspecified error")
        expect(response.status).to eq 400
      end
    end

    it "succeeds" do
      event = Object.new
      expect(Stripe::Webhook).to receive(:construct_event).and_return(event)
      expect(StripeEvent).to receive(:handle).with(event)
      post :receive, body: {}.to_json
      expect(response.body).to eq({}.to_json)
      expect(response.status).to eq 200
    end
  end

  describe "POST #receive_connect" do
    # describe 'authorization' do
    #   include_context :shared_user_context
    #   describe 'accept all' do
    #     describe 'receive' do
    #         include_context :open_to_all, :post, :receive
    #     end
    #   end
    # end

    describe "verification of input" do
      it "returns on bad json" do
        expect(JSON).to receive(:parse).and_raise(JSON::ParserError)
        post :receive_connect
        expect(response.body).to include("Invalid payload")
        expect(response.status).to eq 400
      end

      it "returns on bad signature" do
        post :receive_connect, body: {}.to_json
        expect(response.body).to include("Invalid signature")
        expect(response.status).to eq 400
      end

      it "returns on other error" do
        expect(JSON).to receive(:parse).and_raise(ArgumentError)
        request.headers["HTTP_STRIPE_SIGNATURE"] = ""
        post :receive_connect, body: {}.to_json
        expect(response.body).to include("Unspecified error")
        expect(response.status).to eq 400
      end
    end

    it "succeeds" do
      event = Object.new
      expect(Stripe::Webhook).to receive(:construct_event).and_return(event)
      expect(StripeEvent).to receive(:handle).with(event)
      post :receive_connect, body: {}.to_json
      expect(response.body).to eq({}.to_json)
      expect(response.status).to eq 200
    end
  end
end
