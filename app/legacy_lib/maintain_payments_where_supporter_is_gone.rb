# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module MaintainPaymentsWhereSupporterIsGone

  def self.weird_records()
    Payment.find_by_sql('SELECT payments.* from payments
      LEFT JOIN supporters ON payments.supporter_id = supporters.id
      WHERE payments.supporter_id IS NOT NULL AND supporters.id IS NULL')
  end

  def self.records_by_nonprofit_urgency( records )
    records_by_nonprofit_urgency = records.group_by{|i| i.nonprofit_id}.sort_by{|k,v| v.count}.reverse
    records_by_nonprofit_urgency.map{|k,v| [k, v.count]}.each{|k,v| puts "#{k}: #{v} records"}
    return records_by_nonprofit_urgency
  end

  def self.sorted_by_kind( records )
    sorted_by_kind = records.group_by{|i| i.kind}.sort_by{|k,v| v.count}.reverse
    sorted_by_kind.map{|k,v| [k, v.count]}.each{|k,v| puts "#{k}: #{v} records"}
    return sorted_by_kind
  end

  def self.nonprofit_by_kind( urgency )
    nonprofit_by_kind = urgency.map{|k,v| [k, v.group_by{|i|i.kind}.sort_by{|i,x| x.count}.reverse.map{|i,x| [i, x.count]}]}
    nonprofit_by_kind.each{|id,group| puts id; group.each{|kind, num| puts "  #{kind}: #{num}"}}
    nonprofit_by_kind
  end






  def self.cleanup(sorted_by_kind, api_key)
    Qx.transaction do 
      manual_payments = []

      recurring_donations_from_stripe = sorted_by_kind[1][1].select{|i| i.charge && i.charge.stripe_charge_id && !i.charge.stripe_charge_id.start_with?('legacy')}
      donations_from_stripe = sorted_by_kind[2][1].select{|i| i.charge && i.charge.stripe_charge_id && !i.charge.stripe_charge_id.start_with?('legacy')}
      ticket_from_stripe = sorted_by_kind[3][1].select{|i| i.charge && i.charge.stripe_charge_id && !i.charge.stripe_charge_id.start_with?('legacy')}
      
      payments = recurring_donations_from_stripe.concat(donations_from_stripe).concat(ticket_from_stripe)
      
      payments.each do |i| 
        begin
          unless Supporter.exists?(i.supporter_id) || i.nonprofit_id == 4500
            ch = Stripe::Charge.retrieve(i.charge.stripe_charge_id, {api_key: api_key})
            billing_name = ch.billing_details['name']
            cust = Stripe::Customer.retrieve(ch.customer, {api_key: api_key})
            email = cust.email
      
            #where we save the Supporter
            s = Supporter.create(id: i.supporter_id, name: billing_name, email: email, created_at: i.created_at, nonprofit_id: i.nonprofit_id )
            s.save!
            puts "#{i.supporter_id} is saved"
          else
            puts "#{i.supporter_id} was already saved"
          end
        rescue => e
          puts e

          puts "we failed on #{i.id}"
          manual_payments.push(i)
          
        end
      end
      
      manual_refunds = [] #we have to manually track down these refunds on the connected accounts
      refunds = sorted_by_kind[4][1].select{|i| i.refund && i.refund.stripe_refund_id}
      
      refunds.each do |i|
        begin
          unless Supporter.exists?(i.supporter_id)
            refund = Stripe::Refund.retrieve(i.refund.stripe_refund_id, {api_key: api_key})
            billing_name = refund.billing_details['name']
            cust = Stripe::Customer.retrieve(refund.customer, {api_key: api_key})
            email = cust.email
      
            #where we save the Supporter
            Supporter.create(id: i.supporter_id, name: billing_name, email: email, created_at: i.created_at )
          end
        rescue
          manual_refunds.push(i)
          
        end
      end
      
      disputes = sorted_by_kind[5][1].select{|i| i.dispute && i.dispute.stripe_dispute_id}
      manual_disputes = [] # ditto
      
      disputes.each do |i|
        begin
          unless Supporter.exists?(i.supporter_id)
            dispute = Stripe::Dispute.retrieve(i.refund.stripe_refund_id, {api_key: api_key})
            billing_name = dispute.billing_details['name']
            cust = Stripe::Customer.retrieve(dispute.customer, {api_key: api_key})
            email = cust.email
      
            #where we save the Supporter
            Supporter.create(id: i.supporter_id, name: billing_name, email: email, created_at: i.created_at )
          end
        rescue
          manual_disputes.push(i)
          
        end
      end
      {manual_payments: manual_payments, manual_refunds: manual_refunds, manual_disputes: manual_disputes}
    end
  end
end
