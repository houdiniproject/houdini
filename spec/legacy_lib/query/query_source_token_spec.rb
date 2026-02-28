# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"

describe QuerySourceToken do
  describe ".get_and_increment_source_token" do
    let(:our_uuid) { "7ab66a26-05e5-11e8-b4ef-8f19083c3cc7" } # random uuid I generated
    let(:not_our_uuid) { "a96e3c2c-05e5-11e8-80cc-177b86bb74cd" } # ditto
    let(:fake_uuid) { "15c13da0-05e8-11e8-9cc0-e7ccb95e5f1f" } # ditto
    let(:expired_uuid) { "061124ca-05f1-11e8-8730-57558ad1064d" }
    let(:overused_uuid) { "0ac67006-05f1-11e8-902c-035df51dbc79" }

    let(:nonprofit) { force_create(:nm_justice) }
    let(:event) { force_create(:event, nonprofit: nonprofit) }
    let(:user) do
      u = force_create(:user)
      force_create(:role, name: :nonprofit_admin, host: nonprofit, user: u)
      u
    end

    let(:other_user) { force_create(:user) }

    let(:our_source_token) { force_create(:source_token, token: our_uuid, total_uses: 0, expiration: Time.now + 1.day, max_uses: 1, event: event) }
    let(:not_our_source_token) { force_create(:source_token, token: not_our_uuid, total_uses: 0, expiration: Time.now + 1.day, max_uses: 1) }

    let(:expired_source_token) { force_create(:source_token, token: expired_uuid, total_uses: 0, expiration: Time.now - 1.day) }
    let(:overused_source_token) { force_create(:source_token, token: overused_uuid, total_uses: 1, expiration: Time.now + 1.day, max_uses: 1) }

    before do
      our_source_token
      not_our_source_token
      expired_source_token
      overused_source_token
    end

    around do |example|
      Timecop.freeze(2020, 5, 4) do
        example.run
      end
    end

    describe "param validation" do
      it "basic validation" do
        expect { QuerySourceToken.get_and_increment_source_token(nil) }.to raise_error { |error|
          expect(error).to be_a ParamValidation::ValidationError
          expect_validation_errors(error.data, [
            {key: :token, name: :required},
            {key: :token, name: :format}
          ])
        }
      end

      it "raises if source_token cant be found" do
        expect { QuerySourceToken.get_and_increment_source_token(fake_uuid) }.to raise_error { |error|
          expect(error).to be_a ParamValidation::ValidationError
          expect_validation_errors(error.data, [
            {key: :token}
          ])
          expect(error.message).to eq "#{fake_uuid} doesn't represent a valid source"
        }
      end

      it "raises if token already used too much" do
        expect { QuerySourceToken.get_and_increment_source_token(overused_uuid) }.to raise_error { |error|
          expect(error).to be_a ExpiredTokenError
        }
      end

      it "raises if token expired" do
        expect { QuerySourceToken.get_and_increment_source_token(expired_uuid) }.to raise_error { |error|
          expect(error).to be_a ExpiredTokenError
        }
      end

      it "raises authentication error if event on it but user is nil" do
        expect { QuerySourceToken.get_and_increment_source_token(our_uuid) }.to raise_error { |error|
          expect(error).to be_a AuthenticationError
        }
      end

      it "raises authentication error if event on it but user is not with nonprofit" do
        expect { QuerySourceToken.get_and_increment_source_token(our_uuid, other_user) }.to raise_error { |error|
          expect(error).to be_a AuthenticationError
        }
      end
    end

    it "increments and returns source token" do
      result = QuerySourceToken.get_and_increment_source_token(our_uuid, user)
      expect(result).to be_a SourceToken

      expected = {
        total_uses: 1,
        max_uses: 1,
        created_at: Time.now,
        updated_at: Time.now,
        event_id: event.id,
        expiration: Time.now + 1.day,
        token: our_uuid,
        tokenizable_id: nil,
        tokenizable_type: nil
      }.with_indifferent_access

      expect(result.attributes).to eq expected

      reload_all_tokens
      expect(our_source_token.attributes).to eq expected
    end

    def reload_all_tokens
      our_source_token.reload
      not_our_source_token.reload
      expired_source_token.reload
      overused_source_token.reload
    end
  end
end
