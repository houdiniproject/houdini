# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'

RSpec.describe Nonprofit, type: :model do
  describe 'with cards' do
    before(:each) do
      @nonprofit = create(:nm_justice)

      @card1 = create(:card, holder: @nonprofit, name: 'card1')
      @card2 = create(:card, holder: @nonprofit, name: 'card2')
      @card3 = create(:card, holder: @nonprofit, name: 'card3', inactive:true)
    end
    describe '.active_cards' do
      it 'should return all cards' do
        cards = @nonprofit.active_cards
        expect(cards.length).to eq(2)
      end
    end
    describe '.active_card' do
      it 'should return one' do
        card = @nonprofit.active_card
        expect(card).to_not be_nil
      end
    end
    describe '.create_active_card' do
      it 'should become active and turn others inactive' do
        previously_active_cards = @nonprofit.active_cards
        card = @nonprofit.create_active_card(name: 'card 4')
        expect(card).to_not be_nil
        expect(card.name).to eq(@nonprofit.active_card.name)
        expect(!card.inactive)
      end
    end
  end

  describe '.currency_symbol' do
    let(:nonprofit) { force_create(:nm_justice, currency: 'eur') }
    let(:euro) { '€' }

    it 'finds correct currency symbol for nonprofit' do
      expect(nonprofit.currency_symbol).to eq euro
    end
  end
end
