# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'

describe DefaultAddressStrategies do
  include_context :shared_donation_charge_context
  describe DefaultAddressStrategies::ManualStrategy do

    def expected_default(result, address)
      expect(result.name).to eq 'default'
      expect(result.supporter).to eq supporter
      expect(result.address).to eq address
    end

    describe '.on_add' do

      it 'no default' do
        result = subject.on_add(supporter, supporter_address)

        expected_default(result, supporter_address)

      end

      it 'already default' do

        subject.on_add(supporter, supporter_address_2)

        result = subject.on_add(supporter, supporter_address)

        expected_default(result, supporter_address_2)

      end
    end

    describe '.on_modify_default_request' do
      it 'no default' do
        result = subject.on_modify_default_request(supporter, supporter_address)


        expected_default result, supporter_address
      end

      it 'already default' do

        subject.on_add(supporter, supporter_address_2)

        result = subject.on_modify_default_request(supporter, supporter_address)
        expected_default result, supporter_address
      end
    end

    describe '.on_use' do
      it 'no default' do
        result = subject.on_use(supporter, supporter_address)


        expected_default result, supporter_address
      end

      it 'already default' do

        subject.on_add(supporter, supporter_address_2)

        result = subject.on_use(supporter, supporter_address)
        expected_default result, supporter_address_2
      end
    end

    describe '.on_remove' do
      it 'no default' do
        supporter_address.destroy
        result = subject.on_remove(supporter, supporter_address)
        expect(result).to be_nil
      end

      it 'we have default but its not supporter address' do
        subject.on_add(supporter, supporter_address_2)
        supporter_address.destroy
        result = subject.on_remove(supporter, supporter_address)
        expected_default result, supporter_address_2
      end

      it 'we have default, its us but no others addresses exist' do
        subject.on_add(supporter, supporter_address)
        supporter_address.destroy
        result = subject.on_remove(supporter, supporter_address)
        expect(result).to be_nil
      end

      it 'we have default, its us and we have other addresses' do
        supporter_address_2

        subject.on_add(supporter, supporter_address)
        supporter_address.deleted = true
        supporter_address.save!
        result = subject.on_remove(supporter, supporter_address)
        expected_default result, supporter_address_2
      end


    end
  end

  describe DefaultAddressStrategies::AlwaysFirstStrategy do

    def expected_default(result, address)
      expect(result.name).to eq 'default'
      expect(result.supporter).to eq supporter
      expect(result.address).to eq address
    end

    describe '.on_add' do

      it 'no default' do
        result = subject.on_add(supporter, supporter_address)

        expected_default(result, supporter_address)

      end

      it 'already default' do

        subject.on_add(supporter, supporter_address_2)

        result = subject.on_add(supporter, supporter_address)

        expected_default(result, supporter_address_2)

      end
    end

    describe '.on_modify_default_request' do
      it 'no default' do
        result = subject.on_modify_default_request(supporter, supporter_address)


        expected_default result, supporter_address
      end

      it 'already default' do

        subject.on_add(supporter, supporter_address_2)

        result = subject.on_modify_default_request(supporter, supporter_address)
        expected_default result, supporter_address_2
      end
    end

    describe '.on_use' do
      it 'no default' do
        result = subject.on_use(supporter, supporter_address)


        expected_default result, supporter_address
      end

      it 'already default' do

        subject.on_add(supporter, supporter_address_2)

        result = subject.on_use(supporter, supporter_address)
        expected_default result, supporter_address_2
      end
    end
  end

  describe DefaultAddressStrategies::AlwaysLastStrategy do

    def expected_default(result, address)
      expect(result.name).to eq 'default'
      expect(result.supporter).to eq supporter
      expect(result.address).to eq address
    end

    describe '.on_add' do

      it 'no default' do
        result = subject.on_add(supporter, supporter_address)

        expected_default(result, supporter_address)

      end

      it 'already default' do

        subject.on_add(supporter, supporter_address_2)

        result = subject.on_add(supporter, supporter_address)

        expected_default(result, supporter_address)

      end
    end

    describe '.on_modify_default_request' do
      it 'no default' do
        result = subject.on_modify_default_request(supporter, supporter_address)


        expected_default result, supporter_address
      end

      it 'already default' do

        subject.on_add(supporter, supporter_address_2)

        result = subject.on_modify_default_request(supporter, supporter_address)
        expected_default result, supporter_address_2
      end
    end

    describe '.on_use' do
      it 'no default' do
        result = subject.on_use(supporter, supporter_address)


        expected_default result, supporter_address
      end

      it 'already default' do

        subject.on_add(supporter, supporter_address_2)

        result = subject.on_use(supporter, supporter_address)
        expected_default result, supporter_address
      end
    end
  end
end