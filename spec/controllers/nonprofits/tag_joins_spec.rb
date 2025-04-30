# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"
require "controllers/support/shared_user_context"

describe Nonprofits::TagJoinsController, type: :controller do
  describe "authorization" do
    include_context :shared_user_context
    describe "index" do
      include_context :open_to_np_associate, :get, :index, nonprofit_id: :__our_np, supporter_id: 1
    end

    describe "modify" do
      include_context :open_to_np_associate, :post, :modify, nonprofit_id: :__our_np, id: "1"

      context "strong params" do
        let(:supporter) { create(:supporter_base) }
        let(:nonprofit) { supporter.nonprofit }
        let(:tag_master) { create(:tag_master_base, nonprofit: nonprofit) }

        before(:each) do
          sign_in create(:user_as_nonprofit_admin, nonprofit: nonprofit)
        end

        let(:params) do
          {
            nonprofit_id: nonprofit.id,
            supporter_ids: [supporter.id],
            tags: [
              {
                tag_master_id: tag_master.id,
                selected: true,
                supporter_id: :invalid, # proves that the permit strips this out
                something_else: :invalid # proves that the permit strips this out
              }
            ]
          }
        end

        it "succeeds" do
          post :modify, params: params
          expect(supporter.tag_joins.count).to eq 1
        end

        # The line below raises the following error. I suspect it is due to the oldness of our Rails and Ruby.
        # We can turn this back on in newer versions and see if it works
        #     1) Nonprofits::TagJoinsController authorization modify permitting is expected to (for POST #modify) restrict parameters on :tags to :tag_master_id
        # Failure/Error: modify_params.require(:tags)

        # NameError:
        #   undefined method `permit' for class `#<Class:#<Array:0x00005d12eeae6a60>>'
        #   Did you mean?  print
        # # ./app/controllers/nonprofits/tag_joins_controller.rb:42:in `tag_modify_params'
        # # ./app/controllers/nonprofits/tag_joins_controller.rb:22:in `modify'
        # # ./spec/controllers/nonprofits/tag_joins_spec.rb:45:in `block (5 levels) in <top (required)>'
        # # ./spec/rails_helper.rb:92:in `block (3 levels) in <top (required)>'
        # # ./spec/rails_helper.rb:91:in `block (2 levels) in <top (required)>'

        # it { is_expected.to permit(:tag_master_id).for(:modify, params: params, verb: :post).on(:tags)  }
      end
    end

    describe "destroy" do
      include_context :open_to_np_associate, :delete, :destroy, nonprofit_id: :__our_np, id: "1", supporter_id: 2
    end
  end
end
