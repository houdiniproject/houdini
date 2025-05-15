# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

describe InsertSourceToken do
  describe ".create_record" do
    let(:event) { force_create(:event, end_datetime: Time.now + 1.day) }
    describe "param validation" do
      it "validates tokenizable" do
        expect { InsertSourceToken.create_record(nil) }.to(raise_error { |error|
          expect(error).to be_a ParamValidation::ValidationError
          expect_validation_errors(error.data, [{key: :tokenizable, name: :required}])
        })
      end

      it "validates params" do
        expect { InsertSourceToken.create_record(nil, event: "", expiration_time: "j", max_uses: "j") }.to(raise_error { |error|
          expect(error).to be_a ParamValidation::ValidationError
          expect_validation_errors(error.data, [
            {key: :tokenizable, name: :required},
            {key: :event, name: :is_a},
            {key: :expiration_time, name: :is_integer},
            {key: :expiration_time, name: :min},
            {key: :max_uses, name: :is_integer},
            {key: :max_uses, name: :min}
          ])
        })
      end
    end
    describe "handles default" do
      it "without event" do
        Timecop.freeze(2020, 4, 5) do
          ouruuid = nil

          tokenizable = Card.create!
          expect(SecureRandom).to receive(:uuid).and_wrap_original { |m|
            ouruuid = m.call
            ouruuid
          }

          result = InsertSourceToken.create_record(tokenizable)

          expected = {
            tokenizable_id: tokenizable.id,
            tokenizable_type: "Card",
            token: ouruuid,
            expiration: Time.now.since(20.minutes),
            created_at: Time.now,
            updated_at: Time.now,
            total_uses: 0,
            max_uses: 1,
            event_id: nil
          }.with_indifferent_access

          expect(result.attributes.with_indifferent_access).to eq expected

          expect(SourceToken.last.attributes).to eq expected
        end
      end

      it "with event" do
        Timecop.freeze(2020, 4, 5) do
          ouruuid = nil

          tokenizable = Card.create!
          expect(SecureRandom).to receive(:uuid).and_wrap_original { |m|
            ouruuid = m.call
            ouruuid
          }

          result = InsertSourceToken.create_record(tokenizable, event: event)

          expected = {
            tokenizable_id: tokenizable.id,
            tokenizable_type: "Card",
            token: ouruuid,
            expiration: Time.now + 1.day + 20.days,
            created_at: Time.now,
            updated_at: Time.now,
            total_uses: 0,
            max_uses: 20,
            event_id: event.id
          }.with_indifferent_access

          expect(result.attributes).to eq expected

          expect(SourceToken.last.attributes).to eq expected
        end
      end
    end
    describe "handles passed in data" do
      it "without event" do
        Timecop.freeze(2020, 4, 5) do
          ouruuid = nil

          tokenizable = Card.create!
          expect(SecureRandom).to receive(:uuid).and_wrap_original { |m|
            ouruuid = m.call
            ouruuid
          }

          result = InsertSourceToken.create_record(tokenizable, max_uses: 50, expiration_time: 3600)

          expected = {tokenizable_id: tokenizable.id,
                      tokenizable_type: "Card",
                      token: ouruuid,
                      expiration: Time.now.since(1.hour),
                      created_at: Time.now,
                      updated_at: Time.now,
                      total_uses: 0,
                      max_uses: 50,
                      event_id: nil}.with_indifferent_access

          expect(result.attributes.with_indifferent_access).to eq expected
          expect(SourceToken.last.attributes).to eq expected
        end
      end

      it "with event" do
        Timecop.freeze(2020, 4, 5) do
          ouruuid = nil

          tokenizable = Card.create!
          expect(SecureRandom).to receive(:uuid).and_wrap_original { |m|
            ouruuid = m.call
            ouruuid
          }

          result = InsertSourceToken.create_record(tokenizable, max_uses: 50, expiration_time: 3600, event: event)

          expected = {
            tokenizable_id: tokenizable.id,
            tokenizable_type: "Card",
            token: ouruuid,
            expiration: Time.now.since(1.day).since(1.hour),
            created_at: Time.now,
            updated_at: Time.now,
            total_uses: 0,
            max_uses: 50,
            event_id: event.id
          }.with_indifferent_access

          expect(result.attributes.with_indifferent_access).to eq expected
          expect(SourceToken.last.attributes).to eq expected
        end
      end
    end
  end
end
