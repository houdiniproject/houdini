# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

RSpec.describe DisputeMailer, :type => :mailer do
  before(:each) do
    StripeMock.start
  end
  let(:nonprofit) { force_create(:nonprofit, name: "Nonprofit Name")}
  let(:json) do
    event =StripeMock.mock_webhook_event('charge.dispute.created')
    event['data']['object']
  end
  let(:supporter) { force_create(:supporter, nonprofit: nonprofit)}
  let!(:charge) { force_create(:charge, supporter: supporter, 
    stripe_charge_id: 'ch_1Y7zzfBCJIIhvMWmSiNWrPAC', nonprofit: nonprofit, payment:force_create(:payment,
       supporter:supporter,
      nonprofit: nonprofit,
      gross_amount: 80000))}

  let(:obj) { StripeDispute.create(object:json) }
  let(:dispute) { obj.dispute }

  describe "created" do
    let(:mail) { DisputeMailer.created(dispute) }

    it "renders the headers" do
      expect(mail.subject).to eq("New dispute dp_05RsQX2eZvKYlo2C0FRTGSSA for Nonprofit Name, evidence due on 2020-08-19 23:59:59 UTC")
      expect(mail.to).to eq(["support@commitchange.com"])
      expect(mail.from).to eq(["support@commitchange.com"])
    end
  end

  describe "funds_withdrawn" do
    before(:each) do
      StripeMock.start
    end
    let(:nonprofit) { force_create(:nonprofit, name: "Nonprofit Name")}
    let(:json) do
      event =StripeMock.mock_webhook_event('charge.dispute.closed-lost')
      event['data']['object']
    end
    let(:supporter) { force_create(:supporter, nonprofit: nonprofit)}
    let!(:charge) { force_create(:charge, supporter: supporter, 
      stripe_charge_id: 'ch_1Y7zzfBCJIIhvMWmSiNWrPAC', nonprofit: nonprofit, payment:force_create(:payment,
         supporter:supporter,
        nonprofit: nonprofit,
        gross_amount: 80000))}
  
    let(:obj) { StripeDispute.create(object:json) }
    let(:dispute) { obj.dispute }
    let(:mail) { DisputeMailer.funds_withdrawn(dispute) }

    it "renders the headers" do
      expect(mail.subject).to eq("-$815 withdrawn for dispute dp_05RsQX2eZvKYlo2C0FRTGSSA for Nonprofit Name, evidence due on 2020-08-19 23:59:59 UTC")
      expect(mail.to).to eq(["support@commitchange.com"])
      expect(mail.from).to eq(["support@commitchange.com"])
    end
  end

  describe "funds_reinstated" do
    before(:each) do
      StripeMock.start
    end
    let(:nonprofit) { force_create(:nonprofit, name: "Nonprofit Name")}
    let(:json) do
      event =StripeMock.mock_webhook_event('charge.dispute.closed-won')
      event['data']['object']
    end
    let(:supporter) { force_create(:supporter, nonprofit: nonprofit)}
    let!(:charge) { force_create(:charge, supporter: supporter, 
      stripe_charge_id: 'ch_1Y7vFYBCJIIhvMWmsdRJWSw5', nonprofit: nonprofit, payment:force_create(:payment,
         supporter:supporter,
        nonprofit: nonprofit,
        gross_amount: 22500))}
  
    let(:obj) { StripeDispute.create(object:json) }
    let(:dispute) { obj.dispute }
    let(:mail) { DisputeMailer.funds_reinstated(dispute) }

    it "renders the headers" do
      expect(mail.subject).to eq("-$240 reinstated for dispute dp_15RsQX2eZvKYlo2C0ERTYUIA for Nonprofit Name")
      expect(mail.to).to eq(["support@commitchange.com"])
      expect(mail.from).to eq(["support@commitchange.com"])
    end
  end

  describe "won" do
    before(:each) do
      StripeMock.start
    end
    let(:nonprofit) { force_create(:nonprofit, name: "Nonprofit Name")}
    let(:json) do
      event =StripeMock.mock_webhook_event('charge.dispute.closed-won')
      event['data']['object']
    end
    let(:supporter) { force_create(:supporter, nonprofit: nonprofit)}
    let!(:charge) { force_create(:charge, supporter: supporter, 
      stripe_charge_id: 'ch_1Y7vFYBCJIIhvMWmsdRJWSw5', nonprofit: nonprofit, payment:force_create(:payment,
         supporter:supporter,
        nonprofit: nonprofit,
        gross_amount: 22500))}
  
    let(:obj) { StripeDispute.create(object:json) }
    let(:dispute) { obj.dispute }
    let(:mail) { DisputeMailer.won(dispute) }

    it "renders the headers" do
      expect(mail.subject).to eq("WON dispute dp_15RsQX2eZvKYlo2C0ERTYUIA for Nonprofit Name")
      expect(mail.to).to eq(["support@commitchange.com"])
      expect(mail.from).to eq(["support@commitchange.com"])
    end
  end

  describe "lost" do
    before(:each) do
      StripeMock.start
    end
    let(:nonprofit) { force_create(:nonprofit, name: "Nonprofit Name")}
    let(:json) do
      event =StripeMock.mock_webhook_event('charge.dispute.closed-lost')
      event['data']['object']
    end
    let(:supporter) { force_create(:supporter, nonprofit: nonprofit)}
    let!(:charge) { force_create(:charge, supporter: supporter, 
      stripe_charge_id: 'ch_1Y7zzfBCJIIhvMWmSiNWrPAC', nonprofit: nonprofit, payment:force_create(:payment,
         supporter:supporter,
        nonprofit: nonprofit,
        gross_amount: 80000))}
  
    let(:obj) { StripeDispute.create(object:json) }
    let(:dispute) { obj.dispute }
    let(:mail) { DisputeMailer.lost(dispute) }

    it "renders the headers" do
      expect(mail.subject).to eq("LOST dispute dp_05RsQX2eZvKYlo2C0FRTGSSA for Nonprofit Name")
      expect(mail.to).to eq(["support@commitchange.com"])
      expect(mail.from).to eq(["support@commitchange.com"])
    end
  end

  describe "update" do
    before(:each) do
      StripeMock.start
    end
    let(:nonprofit) { force_create(:nonprofit, name: "Nonprofit Name")}
    let(:json) do
      event =StripeMock.mock_webhook_event('charge.dispute.updated')
      event['data']['object']
    end
    let(:supporter) { force_create(:supporter, nonprofit: nonprofit)}
    let!(:charge) { force_create(:charge, supporter: supporter, 
      stripe_charge_id: 'ch_1Y7vFYBCJIIhvMWmsdRJWSw5', nonprofit: nonprofit, payment:force_create(:payment,
         supporter:supporter,
        nonprofit: nonprofit,
        gross_amount: 22500))}
  
    let(:obj) { StripeDispute.create(object:json) }
    let(:dispute) { obj.dispute }
    let(:mail) { DisputeMailer.updated(dispute) }

    it "renders the headers" do
      expect(mail.subject).to eq("Updated dispute dp_15RsQX2eZvKYlo2C0ERTYUIA for Nonprofit Name, evidence due on 2019-09-16 00:59:59 UTC")
      expect(mail.to).to eq(["support@commitchange.com"])
      expect(mail.from).to eq(["support@commitchange.com"])
    end
  end

end
