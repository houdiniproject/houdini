# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'

describe InsertSupporter do
  describe '.create_or_update' do
    let (:nonprofit) { force_create(:nonprofit)}
    describe 'parameter validation' do
      it 'errors when no np_id provided' do
        expect { InsertSupporter.create_or_update(nil) }.to raise_error {|error|
          expect(error).to be_a ParamValidation::ValidationError
          expect_validation_errors(error.data, [
            {key: :np_id, name: :required},
            {key: :np_id, name: :is_integer},
          ])
        }
      end
      it 'errors when nonprofit is invalid' do
        expect { InsertSupporter.create_or_update(9999)}.to raise_error do |error|
          expect(error).to be_a ActiveRecord::RecordNotFound
        end
      end
    end

    it 'supporter with blank name email should always create a new data' do
      original_supporter = force_create(:supporter, nonprofit: nonprofit)
      result = InsertSupporter.create_or_update(nonprofit.id, {})
      expect(original_supporter).to_not eq result
    end

    it 'we get the original supporter and update when they match' do
      original_supporter = force_create(:supporter, nonprofit: nonprofit, name: "wtewn", email: " email@email.com")
      result = InsertSupporter.create_or_update(nonprofit.id, {name: " WTEWn   ", email:"email@email.com "})
      expect(original_supporter).to eq result
    end

    it 'only updates non original fields of the supporter' do 
      original_supporter = force_create(:supporter, nonprofit: nonprofit, name: "a name", organization: 'org', email: " email@email.com")

      result = InsertSupporter.create_or_update(nonprofit.id, {email:"email@email.com "})

      expect(original_supporter).to eq result
      original_supporter.reload

      expect(original_supporter.attributes.slice('name', 'organization', 'phone')).to eq({'name' => 'a name', "organization" => "org", "phone" =>  nil})
    end
  end
end



