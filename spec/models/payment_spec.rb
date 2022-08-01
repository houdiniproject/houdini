# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'

RSpec.describe Payment, :type => :model do
  it {
    is_expected.to have_one(:subtransaction_payment).with_foreign_key('legacy_payment_id').inverse_of(:legacy_payment)
  }

  it {
    is_expected.to have_one(:trx).class_name('Transaction').through(:subtransaction_payment)
  }
  
  describe '.activities' do
    describe 'Dispute' do
      shared_context :common_specs do
        let(:activity_json) { activity.json_data}
        specify { expect(activity.supporter).to eq supporter}
        specify { expect(activity.nonprofit).to eq nonprofit}
        specify { expect(activity_json['status']).to eq dispute.status }
        specify { expect(activity_json['reason']).to eq dispute.reason }
        specify { expect(activity_json['original_id']).to eq charge.payment.id}
        specify { expect(activity_json['original_kind']).to eq charge.payment.kind}
        specify { expect(activity_json['original_gross_amount']).to eq charge.payment.gross_amount}
        specify { expect(activity_json['original_date']).to eq charge.payment.date}
      end
      
      describe "dispute.funds_withdrawn" do
        include_context :dispute_funds_withdrawn_context
        include_context :common_specs
        let(:obj) { StripeDispute.create(object:json) }
        let(:activity) { withdrawal_payment.activities.build}

        specify { expect(activity.kind).to eq 'DisputeFundsWithdrawn'}
        specify { expect(activity.date).to eq withdrawal_payment.date}
        specify { expect(activity_json['gross_amount']).to eq withdrawal_payment.gross_amount }
        specify { expect(activity_json['fee_total']).to eq withdrawal_payment.fee_total }
        specify { expect(activity_json['net_amount']).to eq withdrawal_payment.net_amount }
      end
    
      # describe "dispute.created AND funds_withdrawn at same time" do 
      #   include_context :dispute_created_and_withdrawn_at_same_time_specs
      #   let(:obj) do 
      #     sd = StripeDispute.create(object:json_created)
      #     sd.object = json_funds_withdrawn
      #     sd.save!
      #     sd
      #   end
      # end
    
      # describe "dispute.created AND funds_withdrawn in order" do 
      #   include_context :dispute_created_and_withdrawn_in_order_specs
      #   let(:obj) do 
      #     sd = StripeDispute.create(object:json_created)
      #     sd.object = json_funds_withdrawn
      #     sd.save!
      #     sd
      #   end
      # end
    
      describe "dispute.funds_reinstated" do
        include_context :dispute_funds_reinstated_context
        include_context :common_specs
        let(:obj) { StripeDispute.create(object:json) }
        let(:activity) { reinstated_payment.activities.build}

        specify { expect(activity.kind).to eq 'DisputeFundsReinstated'}
        specify { expect(activity.date).to eq reinstated_payment.date }
        specify { expect(activity_json['gross_amount']).to eq reinstated_payment.gross_amount }
        specify { expect(activity_json['fee_total']).to eq reinstated_payment.fee_total }
        specify { expect(activity_json['net_amount']).to eq reinstated_payment.net_amount }
      end
    
      # describe "dispute.closed, status = lost" do
      #   include_context :dispute_lost_specs
    
      #   let(:obj) { StripeDispute.create(object:json) }
      # end
    end
  end

  describe '.anonymous' do
    it 'has no payments when none are anonymous' do
      create(:fv_poverty_payment)
      expect(Payment.anonymous.count).to eq 0
    end

    it 'has 1 payment when donation is anonymous' do
      create(:fv_poverty_payment, :anonymous_through_donation)
      expect(Payment.anonymous.count).to eq 1
    end

    it 'has 1 payment when supporter is anonymous' do
      create(:fv_poverty_payment, :anonymous_through_supporter)
      expect(Payment.anonymous.count).to eq 1
    end

    it 'has 1 payment when both supporter and donation are anonymous' do
      create(:fv_poverty_payment, :anonymous_through_supporter,  :anonymous_through_donation)
      expect(Payment.anonymous.count).to eq 1
    end
  end

  describe '.not_anonymous' do

    it 'has 1 payment when none are anonymous' do
      create(:fv_poverty_payment)
      expect(Payment.not_anonymous.count).to eq 1
    end

    it 'has no payments when donation is anonymous' do
      create(:fv_poverty_payment, :anonymous_through_donation)
      expect(Payment.not_anonymous.count).to eq 0
    end

    it 'has no payments when supporter is anonymous' do
      create(:fv_poverty_payment, :anonymous_through_supporter)
      expect(Payment.not_anonymous.count).to eq 0
    end

    it 'has no payments when both supporter and donation are anonymous' do
      create(:fv_poverty_payment, :anonymous_through_supporter, :anonymous_through_donation)
      expect(Payment.not_anonymous.count).to eq 0
    end
  end

  describe '#consider_anonymous?' do
    it 'is false when none are anonymous' do
      expect(create(:fv_poverty_payment)).to_not be_consider_anonymous
    end

    it 'is true when donation is anonymous' do
      expect(create(:fv_poverty_payment, :anonymous_through_donation)).to be_consider_anonymous
    end

    it 'is true when supporter is anonymous' do
      expect(create(:fv_poverty_payment, :anonymous_through_supporter)).to be_consider_anonymous
    end

    it 'is true when both supporter and donation are anonymous' do
      expect(create(:fv_poverty_payment, :anonymous_through_supporter,  :anonymous_through_donation)).to be_consider_anonymous
    end
  end
end