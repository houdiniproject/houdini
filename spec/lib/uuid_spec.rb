# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'
describe UUID do
  describe '::Regex' do
    it 'rejects nil' do
      expect(nil).to_not match(UUID::Regex)
    end

    it 'rejects blank' do
      expect('').to_not match(UUID::Regex)
    end

    it 'rejects non-uuid string' do
      expect('thweoihchnao-n  r -fahc').to_not match(UUID::Regex)
    end

    it 'accepts unbraced uuid' do
      expect(SecureRandom.uuid).to match(UUID::Regex)
    end

    it 'accepts braced uuid' do
      expect("{#{SecureRandom.uuid}}").to match(UUID::Regex)
    end
  end
end
