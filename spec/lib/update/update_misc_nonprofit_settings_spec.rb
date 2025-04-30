# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

describe UpdateMiscellaneousNpInfo do
  describe "#update" do
    describe "validates parameters" do
      it "does basic validation" do
        expect { UpdateMiscellaneousNpInfo.update(nil, nil) }.to(raise_error { |error|
          expect(error).to be_a ParamValidation::ValidationError
          expect_validation_errors(error.data, [{key: :np_id, name: :required},
            {key: :np_id, name: :is_integer},
            {key: :misc_settings, name: :required},
            {key: :misc_settings, name: :is_hash}])
        })
      end

      it "does np validation" do
        expect { UpdateMiscellaneousNpInfo.update(50, {}) }.to(raise_error { |error|
          expect(error).to be_a ParamValidation::ValidationError
          expect_validation_errors(error.data, [{key: :np_id}])
        })
      end
    end

    describe "main" do
      let!(:np) { force_create(:nonprofit) }
      let(:working_message) { "<p>working message</p>" }
      it "sets change_amount_message to nil if empty tags" do
        expect(MiscellaneousNpInfo.count).to eq 0

        update_result = UpdateMiscellaneousNpInfo.update(np.id, {donate_again_url: "url", not_an_attribute: 3, change_amount_message: "<p><br></p>"})
        expect(update_result).to have_attributes donate_again_url: "url", nonprofit: np, change_amount_message: nil
        expect(MiscellaneousNpInfo.count).to eq 1
        expect(update_result).to eq MiscellaneousNpInfo.first!
      end

      it "add misc if it doesnt exist" do
        expect(MiscellaneousNpInfo.count).to eq 0

        update_result = UpdateMiscellaneousNpInfo.update(np.id, {donate_again_url: "url", not_an_attribute: 3, change_amount_message: working_message})
        expect(update_result).to have_attributes donate_again_url: "url", nonprofit: np, change_amount_message: working_message
        expect(MiscellaneousNpInfo.count).to eq 1
        expect(update_result).to eq MiscellaneousNpInfo.first!
      end

      it "update misc if already there" do
        Timecop.freeze(2020, 0o1, 0o5) do
          old_misc = create(:miscellaneous_np_info, nonprofit: np, donate_again_url: "old_url")
          expect(MiscellaneousNpInfo.count).to eq 1
          Timecop.freeze(10) do
            update_result = UpdateMiscellaneousNpInfo.update(np.id, {donate_again_url: "url", not_an_attribute: 3, change_amount_message: working_message})
            expect(update_result).to have_attributes donate_again_url: "url", nonprofit: np, change_amount_message: working_message
            expect(MiscellaneousNpInfo.count).to eq 1
            expect(update_result).to eq MiscellaneousNpInfo.first!

            expect(update_result.created_at).to eq old_misc.created_at
            expect(update_result.updated_at).to be > old_misc.updated_at
          end
        end
      end
    end
  end
end
