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

  describe 'create' do
    describe 'validates on parameters' do
      let(:nonprofit) { Nonprofit.new()}
      let(:nonprofit_with_invalid_user) { Nonprofit.new(user_id: 3333)}
      let(:nonprofit_with_user_who_already_admin) {nonprofit_admin_role; Nonprofit.new(user_id: user.id)}

      let(:nonprofit_with_same_name) { Nonprofit.new({name: "New Mexico Equality", state_code: nm_justice.state_code, city: nm_justice.city, user_id: user.id})}
      let(:nonprofit_with_same_name_but_different_state) { Nonprofit.new({name: "New Mexico Equality", state_code: 'mn', city: nm_justice.city, user_id: user.id })}

      let(:user) { create(:user)}
      let(:nonprofit_admin_role) do
        role = user.roles.build(host: nonprofit, name: 'nonprofit_admin')
        role.save!
        role
      end
      let(:nm_justice) {create(:nm_justice)}

      before(:each) { nonprofit.valid?; nonprofit_with_invalid_user.valid?; nonprofit_with_user_who_already_admin.valid?; nonprofit_with_same_name.valid?; nonprofit_with_same_name_but_different_state.valid?}
      it 'has an error for no name' do
        expect(nonprofit.errors['name'].first).to match /.*blank.*/
      end

      it 'has an error for no user' do
        expect(nonprofit.errors['user_id'].first).to match /.*blank.*/
      end

      it 'has an error for no city' do
        expect(nonprofit.errors['city'].first).to match /.*blank.*/
      end

      it 'has an error for no state' do
        expect(nonprofit.errors['state_code'].first).to match /.*blank.*/
      end

      it 'rejects an invalid user' do 
        expect(nonprofit_with_invalid_user.errors['user_id'].first).to match /.*not a valid user.*/
      end

      it 'rejects a user who is already an admin' do
        expect(nonprofit_with_user_who_already_admin.errors['user_id'].first).to match /.*admin.*/
      end

      it 'accepts and corrects a slug when it tries to save' do
        expect(nonprofit_with_same_name.errors['slug']).to be_empty
        expect(nonprofit_with_same_name.slug).to eq "#{nm_justice.slug}-00"
      end

      it 'does nothing to a slug when it tries to save' do
        expect(nonprofit_with_same_name_but_different_state.errors['slug']).to be_empty
        expect(nonprofit_with_same_name_but_different_state.slug).to eq "#{nm_justice.slug}"
      end
    end
  end
end
