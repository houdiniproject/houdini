# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
json.data do
  json.extract! @payment, :id, :gross_amount, 
            :towards, :net_amount,
            :fee_total, :date, 
            :refund_total, :kind
  
  d_anonymous = @payment.donation.nil? ? false : @payment.donation.anonymous
  json.consider_donation_anonymous (!!d_anonymous || !!@payment.supporter.anonymous)
  
  json.charge do
    json.extract! @payment.charge, :created_at, :id, :status
  end

  json.donation do
    d = @payment.donation
    json.extract! d, :designation, :dedication, :origin_url, :id, :comment

    
    json.campaign do
      c = d.campaign 
      json.extract! c, :name, :id
      json.url campaign_locateable_url(c)
    end if d.campaign
    

    json.campaign_gift do
      json.name(d.campaign_gifts.any? ? d.campaign_gifts.last.campaign_gift_option.name : nil)
    end

    json.event(d.event, partial: "events/event", as: :event) if d.event

    json.recurring_donation do
      rd = d.recurring_donation 
      json.extract! rd, :interval, :time_unit, :created_at
    end if d.recurring_donation
  end if @payment.donation

  json.dispute do
    dis =@payment.dispute 
    json.extract! dis, :id, :status, :reason
  end if @payment.dispute

  json.refund do
    ref = @payment.refund
    json.extract! ref, :reason, :comment, :disbursed
  end if @payment.refund

  json.offsite_payment do
    off_p = @payment.offsite_payment
    json.extract! off_p, :check_number, :kind
  end if @payment.offsite_payment

  json.ticket do
      event = @payment.tickets.last.event
      json.event do
        json.extract! event, :name, :id
        json.url event_locateable_url(event)
      end
      json.levels @payment.tickets.map { |t| "#{GetData.chain(t.ticket_level, :name)} (#{t.quantity}x)" }.join(', ')
      json.discount @payment.tickets.map { |t| t.event_discount ? "#{t.event_discount.name} (#{t.event_discount.percent}%)" : nil }.compact.join(', ')
  end if @payment&.tickets&.last&.event

  json.tickets @payment.tickets do |t|
    json.id t.id
    json.ticket_level t.ticket_level, :name
  end if @payment.tickets.any?

  json.supporter do 
    json.extract! @payment.supporter, :name, :email, :city, :state_code, :address, :zip_code, :phone, :id, :country
  end

  json.nonprofit do 
    json.id @payment.nonprofit.id
  end
end