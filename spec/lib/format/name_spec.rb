# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'spec_helper'
require 'format/name'

describe Format::Name do
  describe '.email_from_np' do
    before(:each) do
      Houdini.support_email = 'support@email.com'
    end
    it 'gives the name, minus commas, with our email in brackets' do
      result = Format::Name.email_from_np('Test, X, Y')
      expect(result).to eq('"Test X Y" <support@email.com>')
    end
  end
end
