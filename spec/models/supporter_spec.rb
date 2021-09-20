# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'

RSpec.describe Supporter, type: :model do
  it { is_expected.to have_many(:addresses).class_name("SupporterAddress")}
  it { is_expected.to belong_to(:primary_address).class_name("SupporterAddress")}

  describe "#cleanup_name" do 
    it 'keeps name when no first and last name' do
      s = Supporter.new(name: 'Penelope')
      s.valid?
      expect(s.name).to eq "Penelope"
    end


    it 'keeps copies first to name' do
      s = Supporter.new(name: 'Penelope', first_name: 'Eric')
      s.valid?
      expect(s.name).to eq "Eric"
    end

    it 'copies last to name' do 

      s = Supporter.new(name: 'Penelope', first_name: 'Eric', last_name: 'Schultz')
      s.valid?
      expect(s.name).to eq "Eric Schultz"
    end
    
    it 'copies first and last to name' do 
      s = Supporter.new(first_name: 'Eric', last_name: 'Schultz')
      s.valid?
      expect(s.name).to eq "Eric Schultz"
    end
    
  end


  describe "#cleanup_address" do 
    it 'keeps address when no address_line2' do
      s = Supporter.new(address: '123 Main Street')
      s.valid?
      expect(s.address).to eq '123 Main Street'
    end


    it 'copies no address_line2 when address is empty when' do
      s = Supporter.new()
      s.valid?
      expect(s.address).to be_blank
    end

    it 'combines address and address_line2 when both there' do
      s = Supporter.new(address:'123 Main Street', address_line2: 'Suite 101' )
      s.valid?
      expect(s.address).to eq '123 Main Street Suite 101'
    end
  end


  context 'after_save' do
    describe 'update_primary_address' do
      
      context 'when primary_address is originally nil' do
        subject(:supporter) { create(:supporter_with_fv_poverty) }
        before(:each) {
          supporter.update_attributes(
            address: '123 Main Street',
            city: 'Appleton',
            state_code: "WI",
            zip_code: '54915',
            country: 'United States'
          )
        }
        it { is_expected.to have_attributes(addresses: have_attributes(count: 1))}
        it { is_expected.to have_attributes(primary_address: be_present) }
        it { is_expected.to have_attributes(primary_address: be_persisted)}
        
        context 'and new primary address' do
          subject { supporter.primary_address}
          it {is_expected.to have_attributes(address: '123 Main Street')}
          it {is_expected.to have_attributes(city: 'Appleton')}
          it {is_expected.to have_attributes(state_code: 'WI')}
          it {is_expected.to have_attributes(zip_code: '54915')}
          it {is_expected.to have_attributes(country: 'United States')}
          it {is_expected.to have_attributes(deleted: false)}
        end
      end

      context 'when primary_address originally exists' do
        subject(:supporter) { create(:supporter_with_fv_poverty, :with_primary_address) }
        before(:each) {
          supporter.update_attributes(
            address: '123 Main Street',
            city: 'Appleton',
            state_code: "WI",
            zip_code: '54915',
            country: 'United States'
          )
        }
        it { is_expected.to have_attributes(addresses: have_attributes(count: 1))}
        it { is_expected.to have_attributes(primary_address: be_present) }
        it { is_expected.to have_attributes(primary_address: be_persisted)}
        
        context 'and new primary address' do
          subject { supporter.primary_address}
          it {is_expected.to have_attributes(address: '123 Main Street')}
          it {is_expected.to have_attributes(city: 'Appleton')}
          it {is_expected.to have_attributes(state_code: 'WI')}
          it {is_expected.to have_attributes(zip_code: '54915')}
          it {is_expected.to have_attributes(country: 'United States')}
          it {is_expected.to have_attributes(deleted: false)}
        end
      end
    end
  end
end
