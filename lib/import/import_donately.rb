# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module ImportDonately

    def self.process(nonprofit, donors_csv, subscriptions_csv, stripe_payments_csv)
      donors_import = DonorsCsv.new(donors_csv)
      subscriptions_import = SubscriptionsCsv.new(subscriptions_csv)
      payments_import = StripePaymentsCsv.new(stripe_payments_csv)

      ImportProcessor.new(nonprofit,
                          donors_import,
                          subscriptions_import,
                          payments_import).process
  
  
    end

    class ImportProcessor
  
      def initialize(nonprofit,
                     donors_import,
                     subscriptions_import,
                     payments_import)
        @nonprofit = nonprofit
        @donors_import = donors_import
        @subscriptions_import = subscriptions_import
        @payments_import = payments_import
      end
  
      def process
        Qx.transaction do
          person_to_supporter = @donors_import.rows.map do |row|
            import_a_supporter(row)
          end.to_h

          @subscriptions_import.rows.each do |row|
            supporter = person_to_supporter[row.person_id]
            process_subscription_import(supporter, row)
          end

          @payments_import.rows.each do |row|
            import_a_payment(row, person_to_supporter[row.person_id])
          end
        end
      end
  
      # @param [Supporter] supporter
      # @param [ImportDonately::RecurringDonorsCsv::RecurringDonorRow] row
      def process_subscription_import(supporter, row)
        last_subscription_payment = @payments_import.find_all_by_subscription_id(row.subscription_id).sort_by{|i| i.created_at}[-1]

        # create card

        card = supporter.cards.create(email:supporter.email, name:  last_subscription_payment.card_brand + "*" + last_subscription_payment.card_last4,
        stripe_card_id: last_subscription_payment.stripe_card_id,
        stripe_customer_id: last_subscription_payment.stripe_customer_id)

      
        signup_date = Date.new(2019, 10, row.donation_day.to_i).to_s
      

        

        InsertRecurringDonation.import_with_stripe(supporter_id: supporter.id,
                                                   nonprofit_id: @nonprofit.id,
                                                   amount: row.amount,
                                                   card_id: card.id,
                                                   recurring_donation: {
                                                     paydate: row.donation_day.to_i,
                                                     time_unit: 'month',
                                                     interval: 1,
                                                     start_date: signup_date
                                                   })
  
      end
  
  
  
      def import_a_supporter(row)
        # create the supporter

        address_parts = []
        if (row.address1)
          address_parts.push(row.address1)
        end

        if(row.address2)
          address_parts.push(row.address2)
        end
        address = address_parts.join(" ")

        name_parts = []

        if (row.first_name)
          name_parts.push(row.first_name)
        end
        if (row.last_name)
          name_parts.push(row.last_name)
        end

        name = name_parts.join(' ')

        result = InsertSupporter.create_or_update(@nonprofit.id, {
            email:row.email,
            name: name,
            address: address,
            city: row.city,
            zip_code: row.zip_code,
            state_code: row.state_code,
            country: row.country
        })
        supporter = Supporter.find(result['id'])
  
        [  row.person_id, supporter]
      end

      def import_a_payment(row, supporter)
        InsertDonation.offsite({nonprofit_id: @nonprofit.id,
                               supporter_id: supporter.id,
                               amount: row.amount,
                               date: row.created_at.to_s}.with_indifferent_access)
      end
  
    end
  
    class DonorsCsv
      attr_accessor :rows
      def initialize(csv_filename=nil)
        self.rows = []
        if csv_filename
          CSV.foreach(csv_filename, headers: true) do |row|
            rows.push(process_row(row))
          end
        end
      end

      def process_row(row)
        output = DonorRow.new
        output.person_id = row['Person Id']
        output.first_name = row['Person First Name']
        output.last_name = row['Person Last Name']
        output.phone = row['Person Phone Number']
        output.address1 = row['Person Street Address']
        output.address2 = row['Person Street Address 2']
        output.city = row['Person City']
        output.state_code = row['Person State']
        output.zip_code = row['Person Zip Code']
        output.country = row['Person Country']
  
        output
      end

      class DonorRow
        attr_accessor :person_id, :email, :first_name, :last_name, :phone, :address1, :address2, :city, :state_code, :zip_code, :country 
      end
    end

    class SubscriptionsCsv
      attr_accessor :rows
  
      def initialize(csv_filename=nil)
        self.rows = []
        if csv_filename
          CSV.foreach(csv_filename, headers: true) do |row|
            rows.push(process_row(row))
          end
        end
      end

      def process_row(row)
        output = SubscriptionRow.new
        output.subscription_id = row['Subscription Id']
        output.amount = row['Subscription Amount In Cents']
        output.donation_day = row['Subscription Day Of Month']
        output.person_id = row['Donor Id']
  
        output
      end

      class SubscriptionRow
        attr_accessor :subscription_id, :donation_day, :person_id, :amount
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
        output.stripe_customer_id = row["Customer ID"]
        output.stripe_card_id = row["Card ID"]
        output.status = row["Status"]
        output.subscription_id = row["subscription (metadata)"]
        output.card_brand = row['Card Brand']
        output.card_last4 = row['Card Last4']
        if row['Customer Description'] =~ /.* person: (.+)/
          output.person_id = $1
        end
        
        output
      end

      def find_all_by_subscription_id(subscription_id)
        self.rows.find_all {|row| row.subscription_id == subscription_id}
      end

      class PaymentRow
        attr_accessor :created_at, :amount, :fee, :stripe_customer_id, :status, :stripe_card_id, :subscription_id, :person_id, :card_brand, :card_last4
      end
    end
  end