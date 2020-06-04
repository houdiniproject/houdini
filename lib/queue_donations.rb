# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module QueueDonations
  def self.execute_for_donation(id)
    donation = Donation.find(id)
    return unless donation

    execute([donation])
  end

  def self.execute_all
    donations = fetch_donations
    return if donations.empty?

    donations_ids = donations.collect(&:id)

    execute(donations)
  end

  def self.dry_execute_all
    puts 'dry push donations to civi'
    donations = fetch_donations
    return if donations.empty?

    donations_ids = donations.collect(&:id)

    dry_execute(donations)
  end

  private

  def self.execute(donations)
    push(donations)

    donations_ids = donations.collect(&:id)
    set_queued_for_import_at(donations_ids)
  rescue Bunny::Exception, Bunny::ClientTimeout, Bunny::ConnectionTimeout
    Rails.logger.warn "Bunny error: QueueDonations.execute failed for ids #{donations_ids}"
    nil
  end

  def self.dry_execute(donations)
    push(donations)
  rescue Bunny::Exception, Bunny::ClientTimeout, Bunny::ConnectionTimeout
    Rails.logger.warn "Bunny error: QueueDonations.dry_execute failed for ids #{donations_ids}"
    nil
  end

  def self.push(donations)
    connection = Bunny.new(
      host: Settings.integration.host,
      vhost: Settings.integration.vhost,
      user: Settings.integration.user,
      password: Settings.integration.password
    )
    connection.start
    channel = connection.create_channel
    exchange = channel.topic(Settings.integration.exchange, durable: true)

    donations.each do |donation|
      exchange.publish(
        prepare_donation_params(donation).to_json,
        routing_key: Settings.integration.routing_key
      )
    end

    connection.close
  end

  def self.set_queued_for_import_at(ids)
    timestamp = Time.current
    Qx.update(:donations)
      .where('id IN ($ids)', ids: ids)
      .set(queued_for_import_at: timestamp)
      .execute
  end

  def self.fetch_donations
    Donation
      .where('queued_for_import_at IS null')
      .includes(:supporter, :nonprofit, :tracking, :payment, :recurring_donation)
  end

  def self.prepare_donation_params(donation)
    nonprofit = donation.nonprofit
    tracking = donation.tracking
    campaign = donation.campaign
    recurring = donation.recurring_donation

    action_type = :donate
    action_technical_type = 'cc.wemove.eu:donate'
    action_name = "undefined_#{donation.supporter.locale}"
    external_id = campaign ? campaign.external_identifier : "cc_default_#{nonprofit.id}"

    data = {
      action_type: action_type,
      action_technical_type: action_technical_type,
      create_dt: donation.created_at,
      action_name: action_name || "slug-#{campaign.id}-#{donation.supporter.locale}",
      external_id: external_id || "cc_#{campaign.id}",
      contact: {},
      donation: {}
    }

    data[:contact] = supporter_data(donation.supporter)
    data[:donation] = donation_data(donation)
    data[:source] = tracking_data(donation.tracking) if donation.tracking
    data[:recurring] = recurring_data(donation.recurring_donation) if donation.recurring_donation

    data
  end

  def self.supporter_data(supporter)
    {
      language: supporter.locale,
      firstname: supporter.first_name,
      lastname: supporter.last_name,
      emails: [
        { email: supporter.email }
      ],
      addresses: [
        { zip: supporter.zip_code, country: supporter.country }
      ]
    }
  end

  def self.donation_data(donation)
    common_data = {
      amount: donation.amount / 100.0,
      currency: donation.nonprofit.currency,
      recurring_id: donation.recurring_donation ? "cc_#{donation.recurring_donation.id}" : nil,
      external_identifier: "cc_#{donation.id}",
      type: donation.recurring ? 'recurring' : 'single'
    }

    if donation.card_id
      data = common_data.merge(
        payment_processor: 'stripe',
        amount_charged: donation.payment.charge.amount / 100.0,
        transaction_id: donation.payment.charge.stripe_charge_id,
        status: donation.payment.charge.paid? ? 'success' : 'not_paid'
      )
    elsif donation.direct_debit_detail_id
      data = common_data.merge(
        payment_processor: 'sepa',
        amount_charged: 0,
        transaction_id: "cc_#{donation.id}",
        iban: donation.direct_debit_detail.iban,
        bic: donation.direct_debit_detail.bic,
        account_holder: donation.direct_debit_detail.account_holder_name,
        status: 'success'
      )
    end

    data
  end

  def self.recurring_data(recurring)
    {
      id: recurring.id,
      start: recurring.start_date,
      time_unit: recurring.time_unit,
      active: recurring.active
    }
  end

  def self.tracking_data(tracking)
    {
      source: tracking.utm_source,
      medium: tracking.utm_medium,
      campaign: tracking.utm_campaign,
      content: tracking.utm_content
    }
  end
end
