# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'

describe CalculateFees do
	def create_custom_card(args={})
		args = {last4: "9191", exp_year: 1984}.merge(args)
		token = StripeMock.generate_card_token(args)
		cus = Stripe::Customer.create
		Stripe::Customer.create_source(cus.id, {source: token})
	end

	let(:switchover_date) {Time.new(2020,10,1)}
	
	let(:visa_us) {create_custom_card}
	let(:visa_uk) {create_custom_card(country:'UK') }
	let(:amex_us) {create_custom_card(brand:'American Express')}
	let(:amex_uk) {create_custom_card(brand:'American Express', country: 'UK')}

	around(:each) do |example|
		StripeMock.start
		example.run
		StripeMock.stop
	end

	RSpec.shared_context :validate_errors_on_for_single_amount do
		it 'raises an error with a negative amount' do
			expect{CalculateFees.for_single_amount(-10, {platform_fee:0.01, source: card, switchover_date: switchover_date})}.to raise_error(RuntimeError)
		end
		
		it 'raises an error with a negative fee' do
			expect{CalculateFees.for_single_amount(1000, {platform_fee:-0.01, source: card, switchover_date: switchover_date})}.to raise_error(RuntimeError)
		end
		
		it 'raises an error with an empty source' do 
			expect{CalculateFees.for_single_amount(1000, {platform_fee:0.01, switchover_date: switchover_date})}.to raise_error(RuntimeError)
		end

		it 'raises an error with a negative amount' do
			expect{CalculateFees.for_single_amount(-10, {platform_fee:0.01, source: card})}.to raise_error(RuntimeError)
		end
		
		it 'raises an error with a negative fee' do
			expect{CalculateFees.for_single_amount(1000, {platform_fee:-0.01, source: card})}.to raise_error(RuntimeError)
		end
		
		it 'raises an error with an empty source' do 
			expect{CalculateFees.for_single_amount(1000, {platform_fee:0.01})}.to raise_error(RuntimeError)
		end
	end

	RSpec.shared_context :local_visa_result do
		it 'returns 2.2% + platform fee + 30 cents for an online donation' do
			expect(CalculateFees.for_single_amount(10000, {platform_fee: 0.018, source: card, switchover_date: switchover_date})).to eq(430)
		end

		it 'returns 2.2% + platform fee + 30 cents on small transaction' do
			expect(CalculateFees.for_single_amount(100, {platform_fee: 0.018, source: card, switchover_date: switchover_date})).to eq(34)
		end

		it 'returns 2.2% + + 30 cents for an online donation with no platform fee' do
			expect(CalculateFees.for_single_amount(10000, {source: card, switchover_date: switchover_date})).to eq(250)
		end
		
		it 'returns 2.2% + platform fee + 30 cents for an online donation with higher platform fee' do
			expect(CalculateFees.for_single_amount(10000, {platform_fee:0.038, source: card, switchover_date: switchover_date})).to eq(630)
		end

		include_context :validate_errors_on_for_single_amount
	end
	
	describe '.for_single_amount' do
		describe 'before switchover' do 
			around(:each) do |example|
				Timecop.freeze(switchover_date - 1.day) do
					example.run
				end
			end

			describe 'with local VISA' do
				include_context :local_visa_result do 
					let(:card) {visa_us}
				end
			end
			
			describe 'with foreign VISA' do
				include_context :local_visa_result do 
					let(:card) {visa_uk}
				end
			end

			describe 'with local Amex' do
				include_context :local_visa_result do 
					let(:card) {amex_us}
				end
			end

			describe 'with foreign Amex' do
				include_context :local_visa_result do 
					let(:card) {amex_uk}
				end
			end
		end

		describe 'after switchover' do
			around(:each) do |example|
				Timecop.freeze(switchover_date) do
					example.run
				end
			end

			describe 'with local VISA' do
				include_context :local_visa_result do 
					let(:card) {visa_us}
				end

				describe 'no switchover passed' do
					it 'returns 2.2% + platform fee + 30 cents for an online donation' do
						expect(CalculateFees.for_single_amount(10000, {platform_fee: 0.018, source: card})).to eq(430)
					end
			
					it 'returns 2.2% + platform fee + 30 cents on small transaction' do
						expect(CalculateFees.for_single_amount(100, {platform_fee: 0.018, source: card})).to eq(34)
					end
			
					it 'returns 2.2% + + 30 cents for an online donation with no platform fee' do
						expect(CalculateFees.for_single_amount(10000, {source: card})).to eq(250)
					end
					
					it 'returns 2.2% + platform fee + 30 cents for an online donation with higher platform fee' do
						expect(CalculateFees.for_single_amount(10000, {platform_fee:0.038, source: card})).to eq(630)
					end
				end
			end
			
			describe 'with foreign VISA' do
				let(:card) {visa_uk}
				it 'returns 2.2% + platform fee + 1% international + 30 cents for an online donation' do
					expect(CalculateFees.for_single_amount(10000, {platform_fee: 0.018, source: card, switchover_date: switchover_date})).to eq(530)
				end

				it 'returns 2.2% + platform fee + 1% international + 30 cents on small transaction' do
					expect(CalculateFees.for_single_amount(100, {platform_fee: 0.018, source: card, switchover_date: switchover_date})).to eq(35)
				end
		
				it 'returns 2.2%  + 1% international + 30 cents for an online donation with no platform fee' do
					expect(CalculateFees.for_single_amount(10000, {source: card, switchover_date: switchover_date})).to eq(350)
				end
				
				it 'returns 2.2% + platform fee  + 1% international + 30 cents for an online donation with higher platform fee' do
					expect(CalculateFees.for_single_amount(10000, {platform_fee:0.038, source: card, switchover_date: switchover_date})).to eq(730)
				end

				describe 'no switchover passed' do
					it 'returns 2.2% + platform fee + 1% international + 30 cents for an online donation' do
						expect(CalculateFees.for_single_amount(10000, {platform_fee: 0.018, source: card})).to eq(530)
					end
	
					it 'returns 2.2% + platform fee + 1% international + 30 cents on small transaction' do
						expect(CalculateFees.for_single_amount(100, {platform_fee: 0.018, source: card})).to eq(35)
					end
			
					it 'returns 2.2%  + 1% international + 30 cents for an online donation with no platform fee' do
						expect(CalculateFees.for_single_amount(10000, {source: card})).to eq(350)
					end
					
					it 'returns 2.2% + platform fee  + 1% international + 30 cents for an online donation with higher platform fee' do
						expect(CalculateFees.for_single_amount(10000, {platform_fee:0.038, source: card})).to eq(730)
					end
				end
		
				include_context :validate_errors_on_for_single_amount
			end

			describe 'with local Amex' do
				let(:card) { amex_us}
				it 'returns 3.5% + platform fee for an online donation' do
					expect(CalculateFees.for_single_amount(10000, {platform_fee: 0.018, source: card, switchover_date: switchover_date})).to eq(530)
				end

				it 'returns 3.5% + platform fee on small transaction' do
					expect(CalculateFees.for_single_amount(100, {platform_fee: 0.018, source: card, switchover_date: switchover_date})).to eq(6)
				end
		
				it 'returns 3.5% for an online donation with no platform fee' do
					expect(CalculateFees.for_single_amount(10000, {source: card, switchover_date: switchover_date})).to eq(350)
				end
				
				it 'returns 3.5% + platform fee  for an online donation with higher platform fee' do
					expect(CalculateFees.for_single_amount(10000, {platform_fee:0.038, source: card, switchover_date: switchover_date})).to eq(730)
				end

				describe 'no switchover passed' do
					it 'returns 3.5% + platform fee for an online donation' do
						expect(CalculateFees.for_single_amount(10000, {platform_fee: 0.018, source: card})).to eq(530)
					end
	
					it 'returns 3.5% + platform fee on small transaction' do
						expect(CalculateFees.for_single_amount(100, {platform_fee: 0.018, source: card})).to eq(6)
					end
			
					it 'returns 3.5% for an online donation with no platform fee' do
						expect(CalculateFees.for_single_amount(10000, {source: card})).to eq(350)
					end
					
					it 'returns 3.5% + platform fee  for an online donation with higher platform fee' do
						expect(CalculateFees.for_single_amount(10000, {platform_fee:0.038, source: card})).to eq(730)
					end
				end
		
				include_context :validate_errors_on_for_single_amount
			end

			describe 'with foreign Amex' do
				let(:card) { amex_uk}
				it 'returns 3.5% + 1% international + platform fee for an online donation' do
					expect(CalculateFees.for_single_amount(10000, {platform_fee: 0.018, source: card, switchover_date: switchover_date})).to eq(630)
				end

				it 'returns 3.5% + 1% international + platform fee on small transaction' do
					expect(CalculateFees.for_single_amount(100, {platform_fee: 0.018, source: card, switchover_date: switchover_date})).to eq(7)
				end
		
				it 'returns 3.5% + 1% international for an online donation with no platform fee' do
					expect(CalculateFees.for_single_amount(10000, {source: card, switchover_date: switchover_date})).to eq(450)
				end
				
				it 'returns 3.5% + 1% international + platform fee  for an online donation with higher platform fee' do
					expect(CalculateFees.for_single_amount(10000, {platform_fee:0.038, source: card, switchover_date: switchover_date})).to eq(830)
				end

				describe 'no switchover passed' do
					it 'returns 3.5% + 1% international + platform fee for an online donation' do
						expect(CalculateFees.for_single_amount(10000, {platform_fee: 0.018, source: card})).to eq(630)
					end

					it 'returns 3.5% + 1% international + platform fee on small transaction' do
						expect(CalculateFees.for_single_amount(100, {platform_fee: 0.018, source: card})).to eq(7)
					end
			
					it 'returns 3.5% + 1% international for an online donation with no platform fee' do
						expect(CalculateFees.for_single_amount(10000, {source: card})).to eq(450)
					end
					
					it 'returns 3.5% + 1% international + platform fee  for an online donation with higher platform fee' do
						expect(CalculateFees.for_single_amount(10000, {platform_fee:0.038, source: card})).to eq(830)
					end
				end

				include_context :validate_errors_on_for_single_amount
			end
		end
	end

	describe '.reverse_for_single_amount' do
		

		RSpec.shared_context :local_visa_result_reverse do
			it 'returns 2.2% + platform fee + 30 cents for an online donation' do
				expect_reverse_creates_correct_amount(10000, {platform_fee: 0.018, source: card, switchover_date: switchover_date})
			end
	
			it 'returns 2.2% + platform fee + 30 cents on small transaction' do
				expect_reverse_creates_correct_amount(100, {platform_fee: 0.018, source: card, switchover_date: switchover_date})
			end
	
			it 'returns 2.2% + + 30 cents for an online donation with no platform fee' do
				expect_reverse_creates_correct_amount(10000, {source: card, switchover_date: switchover_date})
			end
			
			it 'returns 2.2% + platform fee + 30 cents for an online donation with higher platform fee' do
				expect_reverse_creates_correct_amount(10000, {platform_fee:0.038, source: card, switchover_date: switchover_date})
			end

			include_context :validate_errors_on_reverse_for_single_amount
		end

		RSpec.shared_context :validate_errors_on_reverse_for_single_amount do
			it 'raises an error with a negative amount' do
				expect{CalculateFees.reverse_for_single_amount(-10, {platform_fee:0.01, source:card})}.to raise_error(RuntimeError)
			end
			
			it 'raises an error with a negative fee' do
				expect{CalculateFees.reverse_for_single_amount(1000, {platform_fee:-0.01, source:card})}.to raise_error(RuntimeError)
			end

			it 'raises an error with no source' do
				expect{CalculateFees.reverse_for_single_amount(1000, {platform_fee:0.01})}.to raise_error(RuntimeError)
			end

			it 'raises an error with a negative amount with switchover_date' do
				expect{CalculateFees.reverse_for_single_amount(-10, {platform_fee:0.01, source:card, switchover_date: switchover_date})}.to raise_error(RuntimeError)
			end
			
			it 'raises an error with a negative fee with switchover_date' do
				expect{CalculateFees.reverse_for_single_amount(1000, {platform_fee:-0.01, source:card, switchover_date: switchover_date})}.to raise_error(RuntimeError)
			end

			it 'raises an error with no source with switchover_date' do
				expect{CalculateFees.reverse_for_single_amount(1000, {platform_fee:0.01, switchover_date: switchover_date})}.to raise_error(RuntimeError)
			end
		end

		describe 'before switchover' do
			def expect_reverse_creates_correct_amount(amount, **args)
				reverse = CalculateFees.reverse_for_single_amount(amount, args)
				total = reverse + amount
				fees_for_reverse = CalculateFees.for_single_amount(total, args)
				expect(total - fees_for_reverse).to eq(amount)
			end

			around(:each) do |example|
				Timecop.freeze(switchover_date - 1.day) do
					example.run
				end
			end

			describe 'with local VISA' do
				include_context :local_visa_result_reverse do 
					let(:card) {visa_us}
				end
			end
			
			describe 'with foreign VISA' do
				include_context :local_visa_result_reverse do 
					let(:card) {visa_uk}
				end
			end

			describe 'with local Amex' do
				include_context :local_visa_result_reverse do 
					let(:card) {amex_us}
				end
			end

			describe 'with foreign Amex' do
				include_context :local_visa_result_reverse do 
					let(:card) {amex_us}
				end
			end
		end

		describe 'after switchover' do
			def expect_reverse_creates_correct_amount(amount, **args)
				reverse = CalculateFees.reverse_for_single_amount(amount, args)
				expect(reverse).to eq((amount * 0.05).ceil.to_i)
			end

			around(:each) do |example|
				Timecop.freeze(switchover_date + 1.second) do
					example.run
				end
			end

			describe 'with local VISA' do
				include_context :local_visa_result do 
					let(:card) {visa_us}
				end

				describe 'no switchover passed' do
					it 'returns 2.2% + platform fee + 30 cents for an online donation' do
						expect_reverse_creates_correct_amount(10000, {platform_fee: 0.018, source: card})
					end
			
					it 'returns 2.2% + platform fee + 30 cents on small transaction' do
						expect_reverse_creates_correct_amount(100, {platform_fee: 0.018, source: card})
					end
			
					it 'returns 2.2% + + 30 cents for an online donation with no platform fee' do
						expect_reverse_creates_correct_amount(10000, {source: card})
					end
					
					it 'returns 2.2% + platform fee + 30 cents for an online donation with higher platform fee' do
						expect_reverse_creates_correct_amount(10000, {platform_fee:0.038, source: card})
					end
				end
			end
			
			describe 'with foreign VISA' do
				let(:card) {visa_uk}
				it 'returns 2.2% + platform fee + 1% international + 30 cents for an online donation' do
					expect_reverse_creates_correct_amount(10000, {platform_fee: 0.018, source: card, switchover_date: switchover_date})
				end

				it 'returns 2.2% + platform fee + 1% international + 30 cents on small transaction' do
					expect_reverse_creates_correct_amount(100, {platform_fee: 0.018, source: card, switchover_date: switchover_date})
				end
		
				it 'returns 2.2%  + 1% international + 30 cents for an online donation with no platform fee' do
					expect_reverse_creates_correct_amount(10000, {source: card, switchover_date: switchover_date})
				end
				
				it 'returns 2.2% + platform fee  + 1% international + 30 cents for an online donation with higher platform fee' do
					expect_reverse_creates_correct_amount(10000, {platform_fee:0.038, source: card, switchover_date: switchover_date})
				end

				describe 'no switchover passed' do
					it 'returns 2.2% + platform fee + 1% international + 30 cents for an online donation' do
						expect_reverse_creates_correct_amount(10000, {platform_fee: 0.018, source: card})
					end
	
					it 'returns 2.2% + platform fee + 1% international + 30 cents on small transaction' do
						expect_reverse_creates_correct_amount(100, {platform_fee: 0.018, source: card})
					end
			
					it 'returns 2.2%  + 1% international + 30 cents for an online donation with no platform fee' do
						expect_reverse_creates_correct_amount(10000, {source: card})
					end
					
					it 'returns 2.2% + platform fee  + 1% international + 30 cents for an online donation with higher platform fee' do
						expect_reverse_creates_correct_amount(10000, {platform_fee:0.038, source: card})
					end 
				end
		
				include_context :validate_errors_on_reverse_for_single_amount
			end

			describe 'with local Amex' do
				let(:card) {amex_us}
				it 'returns 3.5% + platform fee for an online donation' do
					expect_reverse_creates_correct_amount(10000, {platform_fee: 0.018, source: card, switchover_date: switchover_date})
				end

				it 'returns 3.5% + platform fee on small transaction' do
					expect_reverse_creates_correct_amount(100, {platform_fee: 0.018, source: card, switchover_date: switchover_date})
				end
		
				it 'returns 3.5% for an online donation with no platform fee' do
					expect_reverse_creates_correct_amount(10000, {source: card, switchover_date: switchover_date})
				end
				
				it 'returns 3.5% + platform fee  for an online donation with higher platform fee' do
					expect_reverse_creates_correct_amount(10000, {platform_fee:0.038, source: card, switchover_date: switchover_date})
				end

				describe 'no switchover passed' do
					it 'returns 3.5% + platform fee for an online donation' do
						expect_reverse_creates_correct_amount(10000, {platform_fee: 0.018, source: card})
					end
	
					it 'returns 3.5% + platform fee on small transaction' do
						expect_reverse_creates_correct_amount(100, {platform_fee: 0.018, source: card})
					end
			
					it 'returns 3.5% for an online donation with no platform fee' do
						expect_reverse_creates_correct_amount(10000, {source: card})
					end
					
					it 'returns 3.5% + platform fee  for an online donation with higher platform fee' do
						expect_reverse_creates_correct_amount(10000, {platform_fee:0.038, source: card})
					end
				end

				include_context :validate_errors_on_reverse_for_single_amount
			end

			describe 'with foreign Amex' do
				let(:card) {amex_uk}
				it 'returns 3.5% + 1% international + platform fee for an online donation' do
					expect_reverse_creates_correct_amount(10000, {platform_fee: 0.018, source: card, switchover_date: switchover_date})
				end

				it 'returns 3.5% + 1% international + platform fee on small transaction' do
					expect_reverse_creates_correct_amount(100, {platform_fee: 0.018, source: card, switchover_date: switchover_date})
				end
		
				it 'returns 3.5% + 1% international for an online donation with no platform fee' do
					expect_reverse_creates_correct_amount(10000, {source: card, switchover_date: switchover_date})
				end
				
				it 'returns 3.5% + 1% international + platform fee  for an online donation with higher platform fee' do
					expect_reverse_creates_correct_amount(10000, {platform_fee:0.038, source: card, switchover_date: switchover_date})
				end

				describe 'no switchover passed' do
					it 'returns 3.5% + 1% international + platform fee for an online donation' do
						expect_reverse_creates_correct_amount(10000, {platform_fee: 0.018, source: card})
					end
	
					it 'returns 3.5% + 1% international + platform fee on small transaction' do
						expect_reverse_creates_correct_amount(100, {platform_fee: 0.018, source: card})
					end
			
					it 'returns 3.5% + 1% international for an online donation with no platform fee' do
						expect_reverse_creates_correct_amount(10000, {source: card})
					end
					
					it 'returns 3.5% + 1% international + platform fee  for an online donation with higher platform fee' do
						expect_reverse_creates_correct_amount(10000, {platform_fee:0.038, source: card})
					end
				end

				include_context :validate_errors_on_reverse_for_single_amount
			end
		end
	end


	describe '.for_estimated_stripe_fee_on_date' do
		
		RSpec.shared_context :validate_errors_on_for_estimated_stripe_fee_on_date do
			it 'raises an error with a negative amount' do
				expect{CalculateFees.for_estimated_stripe_fee_on_date(-10, date, {platform_fee:0.01, source: card, switchover_date: switchover_date})}.to raise_error(RuntimeError)
			end
			
			it 'raises an error with a negative fee' do
				expect{CalculateFees.for_estimated_stripe_fee_on_date(1000, date, {platform_fee:-0.01, source: card, switchover_date: switchover_date})}.to raise_error(RuntimeError)
			end
			
			it 'raises an error with an empty source' do 
				expect{CalculateFees.for_estimated_stripe_fee_on_date(1000, date, {platform_fee:0.01, switchover_date: switchover_date})}.to raise_error(RuntimeError)
			end
	
			it 'raises an error with a negative amount' do
				expect{CalculateFees.for_estimated_stripe_fee_on_date(-10, date, {platform_fee:0.01, source: card})}.to raise_error(RuntimeError)
			end
			
			it 'raises an error with a negative fee' do
				expect{CalculateFees.for_estimated_stripe_fee_on_date(1000, date, {platform_fee:-0.01, source: card})}.to raise_error(RuntimeError)
			end
			
			it 'raises an error with an empty source' do 
				expect{CalculateFees.for_estimated_stripe_fee_on_date(1000, date, {platform_fee:0.01})}.to raise_error(RuntimeError)
			end
		end
	
		RSpec.shared_context :local_visa_result_for_estimated_stripe_fee_on_date do
			it 'returns 2.2% +30 cents for an online donation' do
				expect(CalculateFees.for_estimated_stripe_fee_on_date(10000, date, {platform_fee: 0.018, source: card, switchover_date: switchover_date})).to eq(250)
			end
	
			it 'returns 2.2% + 30 cents on small transaction' do
				expect(CalculateFees.for_estimated_stripe_fee_on_date(100, date, {platform_fee: 0.018, source: card, switchover_date: switchover_date})).to eq(33)
			end
	
			it 'returns 2.2% +  30 cents for an online donation with no platform fee' do
				expect(CalculateFees.for_estimated_stripe_fee_on_date(10000, date, {source: card, switchover_date: switchover_date})).to eq(250)
			end
			
			it 'returns 2.2% + 30 cents for an online donation with higher platform fee' do
				expect(CalculateFees.for_estimated_stripe_fee_on_date(10000, date, {platform_fee:0.038, source: card, switchover_date: switchover_date})).to eq(250)
			end
	
			include_context :validate_errors_on_for_estimated_stripe_fee_on_date
		end

		describe 'date before switchover' do
			let (:date) { switchover_date - 1.day}
			describe 'with local VISA' do
				include_context :local_visa_result_for_estimated_stripe_fee_on_date do 
					let(:card) {visa_us}
				end
			end
			
			describe 'with foreign VISA' do
				include_context :local_visa_result_for_estimated_stripe_fee_on_date do 
					let(:card) {visa_uk}
				end
			end

			describe 'with local Amex' do
				include_context :local_visa_result_for_estimated_stripe_fee_on_date do 
					let(:card) {amex_us}
				end
			end

			describe 'with foreign Amex' do
				include_context :local_visa_result_for_estimated_stripe_fee_on_date do 
					let(:card) {amex_uk}
				end
			end
		end

		describe 'date after switchover' do
			let (:date) { switchover_date + 1.day}

			describe 'with local VISA' do
				include_context :local_visa_result_for_estimated_stripe_fee_on_date do 
					let(:card) {visa_us}
				end
			end
			
			describe 'with foreign VISA' do
				let(:card) {visa_uk}
				
				it 'returns 2.2%  + 1% international + 30 cents for an online donation' do
					expect(CalculateFees.for_estimated_stripe_fee_on_date(10000, date, {platform_fee: 0.018, source: card, switchover_date: switchover_date})).to eq(350)
				end

				it 'returns 2.2% + 1% international + 30 cents on small transaction' do
					expect(CalculateFees.for_estimated_stripe_fee_on_date(100, date, {platform_fee: 0.018, source: card, switchover_date: switchover_date})).to eq(34)
				end
		
				it 'returns 2.2%  + 1% international + 30 cents for an online donation with no platform fee' do
					expect(CalculateFees.for_estimated_stripe_fee_on_date(10000, date, {source: card, switchover_date: switchover_date})).to eq(350)
				end
				
				it 'returns 2.2%  + 1% international + 30 cents for an online donation with higher platform fee' do
					expect(CalculateFees.for_estimated_stripe_fee_on_date(10000, date, {platform_fee:0.038, source: card, switchover_date: switchover_date})).to eq(350)
				end
			end

			describe 'with local Amex' do
				let(:card) {amex_us}
				it 'returns 3.5% for an online donation' do
					expect(CalculateFees.for_estimated_stripe_fee_on_date(10000, date, {platform_fee: 0.018, source: card, switchover_date: switchover_date})).to eq(350)
				end

				it 'returns 3.5%  on small transaction' do
					expect(CalculateFees.for_estimated_stripe_fee_on_date(100, date, {platform_fee: 0.018, source: card, switchover_date: switchover_date})).to eq(4)
				end
		
				it 'returns 3.5% for an online donation with no platform fee' do
					expect(CalculateFees.for_estimated_stripe_fee_on_date(10000, date, {source: card, switchover_date: switchover_date})).to eq(350)
				end
				
				it 'returns 3.5% for an online donation with higher platform fee' do
					expect(CalculateFees.for_estimated_stripe_fee_on_date(10000, date, {platform_fee:0.038, source: card, switchover_date: switchover_date})).to eq(350)
				end
			
			end

			describe 'with foreign Amex' do
				let(:card) {amex_uk}

				it 'returns 3.5% + 1% international  for an online donation' do
					expect(CalculateFees.for_estimated_stripe_fee_on_date(10000, date, {platform_fee: 0.018, source: card, switchover_date: switchover_date})).to eq(450)
				end

				it 'returns 3.5% + 1% international on small transaction' do
					expect(CalculateFees.for_estimated_stripe_fee_on_date(100, date, {platform_fee: 0.018, source: card, switchover_date: switchover_date})).to eq(5)
				end
		
				it 'returns 3.5% + 1% international for an online donation with no platform fee' do
					expect(CalculateFees.for_estimated_stripe_fee_on_date(10000, date, {source: card, switchover_date: switchover_date})).to eq(450)
				end
				
				it 'returns 3.5% + 1% international for an online donation with higher platform fee' do
					expect(CalculateFees.for_estimated_stripe_fee_on_date(10000, date, {platform_fee:0.038, source: card, switchover_date: switchover_date})).to eq(450)
				end
			end
		end
	end
end
