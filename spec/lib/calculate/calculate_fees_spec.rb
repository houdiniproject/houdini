# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'

describe CalculateFees do

	describe '.for_single_amount' do

		it 'returns 2.2% + platform fee + 30 cents for an online donation' do
			expect(CalculateFees.for_single_amount(10000, 0.018)).to eq(430)
		end
		
    it 'returns 2.2% + + 30 cents for an online donation with no platform fee' do
			expect(CalculateFees.for_single_amount(10000)).to eq(250)
		end
    
    it 'returns 2.2% + platform fee + 30 cents for an online donation with higher platform fee' do
			expect(CalculateFees.for_single_amount(10000, 0.038)).to eq(630)
		end

    it 'raises an error with a negative amount' do
      expect{CalculateFees.for_single_amount(-10, 0.01)}.to raise_error(ParamValidation::ValidationError)
    end
    
    it 'raises an error with a negative fee' do
      expect{CalculateFees.for_single_amount(1000, -0.01)}.to raise_error(ParamValidation::ValidationError)
    end
	end

	describe '.reverse_for_single_amount' do
		it 'returns 2.2% + platform fee + 30 cents for an online donation' do

			reverse = CalculateFees.reverse_for_single_amount(10000, 0.018)
			total = reverse + 10000
			fees_for_reverse = CalculateFees.for_single_amount(total, 0.018)
			expect(total - fees_for_reverse).to eq(10000)
		end
		
	it 'returns 2.2% + + 30 cents for an online donation with no platform fee' do
		
		reverse = CalculateFees.reverse_for_single_amount(10000)
		total = reverse + 10000
		fees_for_reverse = CalculateFees.for_single_amount(total)
		expect(total - fees_for_reverse).to eq(10000)
		end
    
    it 'returns 2.2% + platform fee + 30 cents for an online donation with higher platform fee' do
			
		reverse = CalculateFees.reverse_for_single_amount(10000, 0.038)
		total = reverse + 10000
			fees_for_reverse = CalculateFees.for_single_amount(total, 0.038)
			
			expect(total - fees_for_reverse).to eq(10000)
		end

    it 'raises an error with a negative amount' do
      expect{CalculateFees.reverse_for_single_amount(-10, 0.01)}.to raise_error(ParamValidation::ValidationError)
    end
    
    it 'raises an error with a negative fee' do
      expect{CalculateFees.reverse_for_single_amount(1000, -0.01)}.to raise_error(ParamValidation::ValidationError)
    end
	end

end
