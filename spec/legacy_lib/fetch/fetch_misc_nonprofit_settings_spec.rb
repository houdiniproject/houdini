# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"

describe FetchMiscellaneousNpInfo do
  describe ".fetch" do
    describe "validates params" do
      it "with empty args" do
        expect { FetchMiscellaneousNpInfo.fetch(nil) }.to(raise_error do |error|
          expect(error).to be_a ParamValidation::ValidationError
          expect_validation_errors(error.data, [{key: :np_id, name: :required},
            {key: :np_id, name: :is_integer}])
        end)
      end

      it "with invalid np" do
        expect { FetchMiscellaneousNpInfo.fetch(50) }.to(raise_error do |error|
          expect(error).to be_a ParamValidation::ValidationError
          expect_validation_errors(error.data, [{key: :np_id}])
        end)
      end
    end

    describe "with valid nonprofit" do
      before do
        @np = force_create(:nm_justice)
      end

      it "returns hash with empty misc settings" do
        expect(FetchMiscellaneousNpInfo.fetch(@np.id).attributes).to eq(MiscellaneousNpInfo.new.attributes)
      end

      it "returns the misc if already there" do
        a = force_create(:miscellaneous_np_info, nonprofit: @np, donate_again_url: "http://donateagain.url")
        expect(FetchMiscellaneousNpInfo.fetch(@np.id)).to eq(a)
      end
    end
  end
end
