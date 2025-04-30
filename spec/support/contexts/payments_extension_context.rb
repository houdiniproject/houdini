# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE

shared_examples "a class with payments extension" do |association_attribute, factory|
  let!(:instance) {
    create(factory)
  }

  context "association" do
    let(:association) { instance.send(association_attribute) }

    it {
      expect(association).to have_attributes(gross_amount: 707, net_amount: 700, fee_total: -7)
    }

    it {
      expect(association).to have_attributes(currency: "fake")
    }
  end
end
