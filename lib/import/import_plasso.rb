# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module ImportPlasso

  def self.process(nonprofit, recurring_donor_csv, one_time_csv, stripe_payments_csv, stripe_customer_csv)
    recurring_import = RecurringDonorCsv.new(recurring_donor_csv)
    one_time_import = OneTimeDonorCsv.new(one_time_csv)
    payments_import = StripePaymentsCsv.new(stripe_payments_csv)
    customer_import = StripeCustomerCsv.new(stripe_customer_csv)

    ImportProcessor.new(nonprofit,
                        recurring_import,
                        one_time_import,
                        payments_import,
                        customer_import).process


  end

  def self.calculate_when_paydate_and_start_are(signup_date, monthly=true)
    if monthly
      paydate = signup_date.mday > 28 ? 28 : signup_date.mday

      potential_start_date = Time.utc(Time.now.year, Time.now.month, paydate)

      start_date =  paydate != Time.now.mday && Time.now > potential_start_date ?
                        potential_start_date + 1.month:
                        potential_start_date
    else
      paydate = signup_date.mday > 28 ? 28 : signup_date.mday
      potential_start_date = Time.utc(Time.now.year, signup_date.month, paydate)
      start_date =  Time.now.to_date > potential_start_date.to_date ?
                        potential_start_date + 1.year:
                        potential_start_date
    end
    {paydate: paydate, start_date: start_date}
  end


  class ImportProcessor

    def initialize(nonprofit,
                   recurring_import,
                   one_time_import,
                   payments_import,
                   customer_import)
      @nonprofit = nonprofit
      @recurring_import = recurring_import
      @one_time_import = one_time_import
      @payments_import = payments_import
      @customer_import = customer_import
    end

    def process
      Qx.transaction do
        @one_time_import.rows.each do |row|

          import_a_supporter(row)

        end

        @recurring_import.rows.each do |row|
          supporter = import_a_supporter(row)

          # set up recurring donation
          process_recurring_import(supporter, row)
        end
      end
    end

    # @param [Supporter] supporter
    # @param [ImportPlasso::RecurringDonorCsv::RecurringDonorRow] row
    def process_recurring_import(supporter, row)
      signup_date = ImportPlasso::calculate_when_paydate_and_start_are(row.signup_date, row.period == 'month')

      InsertRecurringDonation.import_with_stripe(supporter_id: supporter.id,
                                                 nonprofit_id: @nonprofit.id,
                                                 amount: row.amount,
                                                 card_id: supporter.cards.first.id,
                                                 recurring_donation: {
                                                   paydate: signup_date[:paydate],
                                                   time_unit: row.period,
                                                   interval: 1,
                                                   start_date: signup_date[:start_date].to_s
                                                 })

    end



    def import_a_supporter(row)
      # create the supporter

      result = InsertSupporter.create_or_update(@nonprofit.id, {
          email:row.email,
          name: row.name,
          anonymous: row.anonymous,
          address: row.address,
          city: row.city,
          zip_code: row.zip,
          state_code: row.state
      })
      supporter = Supporter.find(result['id'])

      puts "stripe_customer_id: #{row.stripe_customer_id}"
      # create the offline import from payments
      payments = @payments_import.find_all_by_customer_id(row.stripe_customer_id)

      puts "length of payments: #{payments.count}"

      payments.select{|p| p.status == 'Paid'}.each do |p|
        puts p.amount
        InsertDonation.offsite({nonprofit_id: @nonprofit.id,
                               supporter_id: supporter.id,
                               amount: p.amount,
                               date: p.created_at.to_s}.with_indifferent_access)
      end

      # create card from @customer_import
      customer_and_card_import = @customer_import.find_by_customer_id(row.stripe_customer_id)

      supporter.cards.create(email:supporter.email,
                                    name: customer_and_card_import.card_brand + '*' + customer_and_card_import.card_last4,
                                    stripe_card_id: customer_and_card_import.stripe_card_id,
                                    stripe_customer_id: customer_and_card_import.stripe_customer_id)
      supporter
    end

  end

  class RecurringDonorCsv
    attr_accessor :rows

    def initialize(csv_filename=nil)
      self.rows = []
      if csv_filename
        CSV.foreach(csv_filename, headers: true) do |row|
          rows.push(process_row(row))
        end
      end
    end

    def find_by_customer_id(cus_id)
      self.rows.find {|row| row.stripe_customer_id == cus_id}
    end

    def process_row(row)
      output = RecurringDonorRow.new
      output.name = row["Member Name"]
      output.email = row["Member Email"]
      output.amount = (row["Subscription Amount"].to_f * 100).to_i
      output.signup_date = DateTime.parse(row["Subscription Sign Up Date"])
      output.payment_method = row["Payment Method"]
      output.stripe_customer_id = row["id"]
      output.anonymous = row['Anonymous'] == "Y"
      output.address = row["Shipping Address"]
      output.city = row["Shipping City"]
      output.state = row["Shipping State"]
      output.zip = row["Shipping ZIP / Postal Code"]

      if row["Subscription Period"] == 'YEAR'
        output.period = 'year'
      elsif row['Subscription Period'] == 'MONTH'
        output.period = 'month'
      end

      output
    end

    class RecurringDonorRow
      attr_accessor :name, :email, :amount, :period,
                    :signup_date, :payment_method, :stripe_customer_id,
                    :anonymous, :address, :city, :state, :zip
    end
  end


  class OneTimeDonorCsv
    attr_accessor :rows

    def initialize(csv_filename = nil)
      self.rows = []
      if csv_filename
        CSV.foreach(csv_filename, headers: true) do |row|
          rows.push(process_row(row))
        end
      end
    end

    def process_row(row)
      output = OneTimeDonorRow.new
      output.name = row["Member Name"]
      output.email = row["Member Email"]
      output.payment_method = row["Payment Method"]
      output.stripe_customer_id = row["id"]
      output.anonymous = row['Anonymous'] == "Y"
      output.address = row["Shipping Address"]
      output.city = row["Shipping City"]
      output.state = row["Shipping State"]
      output.zip = row["Shipping ZIP / Postal Code"]
      output
    end

    def find_by_customer_id(cus_id)
      self.rows.find {|row| row.stripe_customer_id == cus_id}
    end

    class OneTimeDonorRow
      attr_accessor :name, :email, :payment_method, :stripe_customer_id,
                    :anonymous, :address, :city, :state, :zip
    end
  end

  class StripePaymentsCsv
    attr_accessor :rows

    def initialize(csv_filename = nil)

      self.rows = []
      if csv_filename
        CSV.foreach(csv_filename, headers: true) do |row|
          rows.push(process_row(row))
        end
      end
    end

    def process_row(row)
      output = PaymentRow.new
      output.created_at = DateTime.parse(row["Created (UTC)"])
      output.amount = (row["Amount"].to_f * 100).to_i
      #output.fee = row["Fee"] * 100
      output.stripe_customer_id = row["Customer ID"]
      output.status = row["Status"]
      output
    end

    # @return [Array<ImportPlasso::StripePaymentsCsv::PaymentRow>] payments
    def find_all_by_customer_id(cus_id)
      self.rows.find_all {|row| row.stripe_customer_id == cus_id}
    end

    class PaymentRow
      attr_accessor :created_at, :amount, :fee, :stripe_customer_id, :status
    end
  end

  class StripeCustomerCsv
    attr_accessor :rows

    def initialize(csv_filename = nil)

      self.rows = []
      if csv_filename
        CSV.foreach(csv_filename, headers: true) do |row|
          rows.push(process_row(row))
        end
      end
    end

    def process_row(row)
      output = CustomerRow.new
      output.stripe_customer_id = row["id"]
      output.stripe_card_id = row["Card ID"]
      output.card_brand = row["Card Brand"]
      output.card_last4 = row["Card Last4"]
      output
    end


    # @return [CustomerRow]
    def find_by_customer_id(cus_id)
      self.rows.find {|row| row.stripe_customer_id == cus_id}
    end

    class CustomerRow
      attr_accessor :stripe_customer_id, :stripe_card_id, :card_brand, :card_last4
    end
  end
end