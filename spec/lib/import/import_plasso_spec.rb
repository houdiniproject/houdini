# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'

describe ImportPlasso do
  around(:each) do |example|
    Timecop.freeze(2020, 5, 25, 2) do
      StripeMock.start
        example.run
      StripeMock.stop
    end
  end

  describe '.calculate_when_paydate_and_start_are' do

    describe 'monthly' do
      let(:signup_date_with_date_before) { Date.new(2018, 3, 23)}
      let(:signup_date_with_date_of) { Date.new(2018, 3, 25)}
      let(:signup_date_with_date_after) { Date.new(2018, 3, 29)}



      it 'should put the date before into the next month' do
        result = ImportPlasso.calculate_when_paydate_and_start_are(signup_date_with_date_before)
        expect(result[:paydate]).to eq 23
        expect(result[:start_date]).to eq Date.new(2020, 6, 23).to_time
      end

      it 'should put the date of into this month' do
        result = ImportPlasso.calculate_when_paydate_and_start_are(signup_date_with_date_of)
        expect(result[:paydate]).to eq 25
        expect(result[:start_date]).to eq Date.new(2020, 5, 25).to_time
      end

      it 'should put the date after into this month' do
        result = ImportPlasso.calculate_when_paydate_and_start_are(signup_date_with_date_after)
        expect(result[:paydate]).to eq 28
        expect(result[:start_date]).to eq Date.new(2020, 5, 28).to_time
      end
    end

    describe 'annual' do
      let(:signup_date_with_date_before) { Date.new(2018, 3, 23)}
      let(:signup_date_with_date_of) { Date.new(2018, 5, 25)}
      let(:signup_date_with_date_after) { Date.new(2018, 6, 29)}



      it 'should put the date before into the next year' do
        result = ImportPlasso.calculate_when_paydate_and_start_are(signup_date_with_date_before, false)
        expect(result[:paydate]).to eq 23
        expect(result[:start_date]).to eq Date.new(2021, 3, 23).to_time
      end

      it 'should put the date of into this month' do
        result = ImportPlasso.calculate_when_paydate_and_start_are(signup_date_with_date_of, false)
        expect(result[:paydate]).to eq 25
        expect(result[:start_date]).to eq Date.new(2020, 5, 25).to_time
      end

      it 'should put the date after into this month' do
        result = ImportPlasso.calculate_when_paydate_and_start_are(signup_date_with_date_after, false)
        expect(result[:paydate]).to eq 28
        expect(result[:start_date]).to eq Date.new(2020, 6, 28).to_time
      end
    end
  end

  describe '.donation_stuff' do
    let(:nonprofit) { force_create(:nonprofit)}

    let(:one_time_donor_row) do
      row = ImportPlasso::OneTimeDonorCsv::OneTimeDonorRow.new
      row.name = "OneTime donor Name"
      row.email = "one_time@email.com"
      row.payment_method = "MASTERCARD * 2123"
      row.stripe_customer_id = "cus_stripe_id_1"
      row.anonymous= true
      row.address = 'Address 1'
      row.city = 'city 1'
      row.zip = '123455'
      row
    end


    let(:one_time_payment_import_row) do
      row = ImportPlasso::StripePaymentsCsv::PaymentRow.new
      row.created_at = DateTime.new(2001,1,1)
      row.amount = 1200
      row.stripe_customer_id= one_time_donor_row.stripe_customer_id
      row.status = 'Paid'
      row
    end

    let(:one_time_import) do
      result = ImportPlasso::OneTimeDonorCsv.new

      result.rows = [
        one_time_donor_row
      ]

      result
    end


    let(:recurring_donor_row_monthly) do
      row = ImportPlasso::RecurringDonorCsv::RecurringDonorRow.new
      row.name = "Recurring donor Name"
      row.email = "recurring@email.com"
      row.payment_method = "MASTERCARD * 4444"
      row.stripe_customer_id = "cus_stripe_id_2"
      row.anonymous= false
      row.address = 'Address 2'
      row.city = 'city 3'
      row.zip = '123444'
      row.amount= 2300
      row.signup_date= DateTime.new(2012,5,25)
      row.period = "month"
      row
    end

    let(:recurring_payment_import_monthly_row_1) do
      row = ImportPlasso::StripePaymentsCsv::PaymentRow.new
      row.created_at = DateTime.new(2012,5,25)
      row.amount = 2300
      row.stripe_customer_id= recurring_donor_row_monthly.stripe_customer_id
      row.status = 'Paid'
      row
    end

    let(:recurring_payment_import_monthly_row_2) do
      row = ImportPlasso::StripePaymentsCsv::PaymentRow.new
      row.created_at = DateTime.new(2012,6, 25)
      row.amount = 2300
      row.stripe_customer_id= recurring_donor_row_monthly.stripe_customer_id
      row.status = 'Failed'
      row
    end

    let(:recurring_payment_import_monthly_row_3) do
      row = ImportPlasso::StripePaymentsCsv::PaymentRow.new
      row.created_at = DateTime.new(2012,5,26)
      row.amount = 2300
      row.stripe_customer_id= recurring_donor_row_monthly.stripe_customer_id
      row.status = 'Paid'
      row
    end

    let(:recurring_donor_row_annually) do
      row = ImportPlasso::RecurringDonorCsv::RecurringDonorRow.new
      row.name = "annual donor Name"
      row.email = "annual@email.com"
      row.payment_method = "MASTERCARD * 5555"
      row.stripe_customer_id = "cus_stripe_id_3"
      row.anonymous= false
      row.address = 'Address 3'
      row.city = 'city 6'
      row.zip = '12'
      row.amount= 300
      row.signup_date= DateTime.new(2014,5,7)
      row.period = "year"
      row
    end

    let(:recurring_payment_import_annually_row_1) do
      row = ImportPlasso::StripePaymentsCsv::PaymentRow.new
      row.created_at = DateTime.new(2014,5,7)
      row.amount = 300
      row.stripe_customer_id= recurring_donor_row_annually.stripe_customer_id
      row.status = 'Paid'
      row
    end

    let(:recurring_payment_import_annually_row_2) do
      row = ImportPlasso::StripePaymentsCsv::PaymentRow.new
      row.created_at = DateTime.new(2015,5,7)
      row.amount = 300
      row.stripe_customer_id= recurring_donor_row_annually.stripe_customer_id
      row.status = 'Paid'
      row
    end

    let(:recurring_import) do

      import = ImportPlasso::RecurringDonorCsv.new
      import.rows = [
          recurring_donor_row_annually,
          recurring_donor_row_monthly
      ]
      import
    end


    let(:payment_import) do
      result = ImportPlasso::StripePaymentsCsv.new
      result.rows = [
          one_time_payment_import_row,
          recurring_payment_import_monthly_row_1,
          recurring_payment_import_monthly_row_2,
          recurring_payment_import_monthly_row_3,
          recurring_payment_import_annually_row_1,
          recurring_payment_import_annually_row_2
      ]
      result
    end

    let(:customer_import) do
      result = ImportPlasso::StripeCustomerCsv.new

      row1= ImportPlasso::StripeCustomerCsv::CustomerRow.new
      row1.stripe_customer_id= recurring_donor_row_annually.stripe_customer_id
      row1.stripe_card_id = "card 1111"
      row1.card_brand= "MASTERCARD"
      row1.card_last4 = '1234'

      row2 = ImportPlasso::StripeCustomerCsv::CustomerRow.new
      row2.stripe_customer_id = one_time_donor_row.stripe_customer_id
      row2.stripe_card_id = 'card22222'
      row2.card_brand= "VISA"
      row2.card_last4 = '5678'

      row3= ImportPlasso::StripeCustomerCsv::CustomerRow.new
      row3.stripe_customer_id = recurring_donor_row_monthly.stripe_customer_id
      row3.stripe_card_id = 'card 3333'
      row3.card_brand= "AMEX"
      row3.card_last4 = '9876'

      result.rows = [
          row1,
          row2,
          row3
      ]

      result
    end

    before(:each) do
      allow(QueueDonations).to receive(:execute_for_donation)
      ImportPlasso::ImportProcessor.new(nonprofit,
                                        recurring_import,
                                        one_time_import,
                                        payment_import,
                                        customer_import).process
    end

    it 'should have 3 supporters' do
      expect(nonprofit.supporters.count).to eq 3
    end

    it 'should have 6 payments (including one for the new recurring donation today)' do
      expect(nonprofit.payments.count).to eq 6
    end

    it 'should have 2 recurring donations' do
      expect(nonprofit.recurring_donations.count).to eq 2
    end

    describe 'recurring donation starting today' do
      let(:rd) { nonprofit.recurring_donations.select{|rd| rd.start_date.to_date == Date.new(2020,5,25)}.first}
      let(:subject) { rd }
      let(:card) { rd.card}
      let(:donation_card) {rd.donation.card}

      it 'should have one recurring donation with start_date of 5/25/2020' do
        expect(subject).to_not be_nil
      end

      it 'should have one payment on 5/25 for that rd' do
        expect(subject.donation.payments.count).to eq 1
      end

      it 'should have a card which matches' do
        expect(card).to eq donation_card
      end

      describe 'card' do
        let(:subject) { rd.card}

        it 'should have card_id of card 3333' do
          expect(subject.stripe_card_id).to eq 'card 3333'
        end

        it 'should have customer_id of cus_stripe_id_2' do
          expect(subject.stripe_customer_id).to eq 'cus_stripe_id_2'
        end

        it 'should have name of AMEX*9876' do
          expect(subject.name).to eq 'AMEX*9876'
        end
      end


    end

    describe 'recurring donation annual which happened earlier this month' do
      subject { nonprofit.recurring_donations.select{|rd| rd.start_date.to_date == Date.new(2021,5,7)}.first }
      it 'should have one recurring donation with start_date of 5/7/2021' do
        expect(subject).to_not be_nil
      end

      it 'should have no payments' do
        expect(subject.donation.payments.count).to eq 0
      end
    end



  end
end