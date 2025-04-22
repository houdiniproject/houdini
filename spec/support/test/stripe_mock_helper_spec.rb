# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE

describe StripeMockHelper do
  describe "#stripe_helper" do
    it "starts unset" do
      expect(described_class.stripe_helper).to be_falsy
    end

    it "is set on start" do
      described_class.mock do
        expect(described_class.stripe_helper).to be_truthy
      end
    end

    it "clears stripe_helper when finished" do
      described_class.mock do # rubocop:disable Lint/EmptyBlock
      end
      expect(described_class.stripe_helper).to be_falsy
    end
  end

  describe "#start" do
    it "is safely reentrant" do
      described_class.mock do
        # create a plan
        described_class.stripe_helper.create_plan(id: "test_str_plan", amount: 0, currency: "usd", interval: "year",
          name: "test PLan")
        described_class.start
        expect { Stripe::Plan.retrieve("test_str_plan") }.to_not(raise_error, "If this object is not available, \
          then the StripeMockHelper.start is incorrectly creating a new StripeMock session")
      end
    end
  end
end
