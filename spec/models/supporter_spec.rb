# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'

RSpec.describe Supporter, type: :model do
  it { is_expected.to have_many(:addresses).class_name("SupporterAddress")}
  it { is_expected.to belong_to(:primary_address).class_name("SupporterAddress")}


  describe "#calculated_first_name" do
    it "has nil name" do
      supporter = build_stubbed(:supporter, name: nil)
      expect(supporter.calculated_first_name).to be_nil
    end

    it "has blank name" do
      supporter = build_stubbed(:supporter, name: "")
      expect(supporter.calculated_first_name).to be_nil
    end

    it "has one word name" do
      supporter = build_stubbed(:supporter, name: "Penelope")
      expect(supporter.calculated_first_name).to eq "Penelope"
    end

    it "has two word name" do
      supporter = build_stubbed(:supporter, name: "Penelope Schultz")
      expect(supporter.calculated_first_name).to eq "Penelope"
    end

    it "has three word name" do
      supporter = build_stubbed(:supporter, name: "Penelope Rebecca Schultz")
      expect(supporter.calculated_first_name).to eq "Penelope Rebecca"
    end
  end

  describe "#calculated_last_name" do
    it "has nil name" do
      supporter = build_stubbed(:supporter, name: nil)
      expect(supporter.calculated_last_name).to be_nil
    end

    it "has blank name" do
      supporter = build_stubbed(:supporter, name: "")
      expect(supporter.calculated_last_name).to be_nil
    end

    it "has one word name" do
      supporter = build_stubbed(:supporter, name: "Penelope")
      expect(supporter.calculated_last_name).to be_nil
    end

    it "has two word name" do
      supporter = build_stubbed(:supporter, name: "Penelope Schultz")
      expect(supporter.calculated_last_name).to eq "Schultz"
    end

    it "has three word name" do
      supporter = build_stubbed(:supporter, name: "Penelope Rebecca Schultz")
      expect(supporter.calculated_last_name).to eq "Schultz"
    end
  end

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

    it 'replaces blank attributes with nil' do
      s = Supporter.new(address: '')
      s.valid?
      expect(s.address).to be_nil
    end
  end


  context 'after_save' do
    describe 'update_primary_address' do
      def have_one_address
        have_attributes(addresses: have_attributes(count: 1))
      end

      def have_saved_primary_address
        have_attributes(primary_address: be_present)
        have_attributes(primary_address: be_persisted)
      end

      def custom_address_attributes
        attributes_for(:supporter_with_fv_poverty, :with_custom_address_1).slice(:address, :state_code, :country, :zip_code, :city)
      end

      def empty_address_attributes
        attributes_for(:supporter_with_fv_poverty, :with_empty_address).slice(:address, :state_code, :country, :zip_code, :city)
      end

      context 'when primary_address is originally nil' do
        context 'and address is being created' do

          def create_supporter_and_update_supporter_address
            supporter = create(:supporter_with_fv_poverty)
            supporter.update_attributes(custom_address_attributes)
            supporter
          end
          
          it { 
            supporter = create_supporter_and_update_supporter_address
            expect(supporter).to have_one_address
          }

          it { 
            supporter = create_supporter_and_update_supporter_address
            expect(supporter).to have_saved_primary_address
          }
          
          it {
            
            supporter = create_supporter_and_update_supporter_address
            expect(supporter.primary_address).to have_attributes(custom_address_attributes)
            
          }
          

          context 'and the address is being updated to nil attributes' do

            def empty_the_supporter_address(supporter)
              supporter.update(empty_address_attributes)
            end

            it 'removes the primary address from the supporter' do
              supporter = create_supporter_and_update_supporter_address
              empty_the_supporter_address(supporter)
              expect(supporter.primary_address).to be_nil
            end

            it 'deletes the empty primary address from the database' do
              supporter = create_supporter_and_update_supporter_address
              primary_address_id = supporter.primary_address.id
              empty_the_supporter_address(supporter)
              expect(SupporterAddress.where(id: primary_address_id)).to_not be_present
            end
          end
        end

        context 'and the supporter being created has empty address fields' do
          it 'does not create a primary address' do
            supporter = create(:supporter_with_fv_poverty, :with_blank_address)
            expect(supporter.primary_address).to be_nil
          end
        end
      end

      context 'when primary_address originally exists' do

        def create_and_update_supporter_with_already_created_address
          supporter = create(:supporter_with_fv_poverty, :with_primary_address)
          supporter.update(custom_address_attributes)
          supporter
        end
       
        it { 
          supporter = create_and_update_supporter_with_already_created_address
          expect(supporter).to have_one_address
        }

        it { 
          supporter = create_and_update_supporter_with_already_created_address
          expect(supporter).to have_saved_primary_address
        }
        
        it 'has new primary address' do
          supporter = create_and_update_supporter_with_already_created_address
          expect(supporter.primary_address).to have_attributes(custom_address_attributes)
        end
      end
    end
  end
end
