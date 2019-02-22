# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
object @payment => :data

attributes :gross_amount, :towards, :net_amount, :fee_total, :id, :date, :refund_total, :kind

node(:consider_donation_anonymous) do |p|
    d_anonymous = p.donation.nil? ? false : p.donation.anonymous

    !!d_anonymous || !!p.supporter.anonymous
end


child :charge do
	attributes :created_at, :id, :status
end

child :donation, object_root: false do
    attributes :designation, :dedication, :origin_url, :id, :comment


  child :campaign, object_root: false do
  	attributes :name, :url, :id
  end

  node(:campaign_gift){|d| {name: d.campaign_gifts.any? ? d.campaign_gifts.last.campaign_gift_option.name : nil}}

  child :event, object_root: false do
    attributes :name, :url, :id
  end

	child :recurring_donation, object_root: false do
		attributes :interval, :time_unit, :created_at
	end
end

child :dispute, object_root: false do
  attributes :id, :status, :reason
end

child :refund do
	attributes :reason, :comment, :disbursed
end

child :offsite_payment do
	attributes :check_number, :kind
end


node(:ticket) do |payment|
  event = payment&.tickets&.last&.event
  h = {
    event: {name: event&.name, url: event&.url, id: event&.id},
    levels: payment.tickets.map{|t| "#{GetData.chain(t.ticket_level, :name)} (#{t.quantity}x)"}.join(", "),
    discount: payment.tickets.map{|t| t.event_discount ? "#{t.event_discount.name} (#{t.event_discount.percent}%)" : nil}.compact.join(", ")
  }
  event ? h : nil
end

child :tickets, object_root: false do
	attributes :id

	child :ticket_level do
		attributes :name
	end
end

child :supporter do
	attributes :name, :email, :city, :state_code, :address, :zip_code, :phone, :id, :country

end

child :nonprofit do
    attributes :id
end
