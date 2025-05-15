# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module MaintainDonationValidity
  # some tickets have invalid records. Find them.
  def self.get_invalid_donations
    invalid = []

    Donation.includes({supporter: :nonprofit}, {payment: :supporter}, :nonprofit, :campaign_gifts, :campaign).find_each(batch_size: 10000) do |d|
      donation = {donation: d, issues: []}

      first_level(donation)

      if donation[:issues].any?
        invalid.push(donation)
      else
        second_level(donation)
        if donation[:issues].any?
          invalid.push(donation)
        end
      end
    end

    # second_level(tickets)
    # a, tickets = tickets.partition{|i| i[:issues].any?}
    # invalid = invalid.concat(a)
    invalid
  end

  # some tickets have valid records, format a report of them
  def self.report(invalid_records)
    invalid_records.map { |d|
      donation = d[:donation]
      {
        donation_id: donation.id,
        donation_nonprofit_id: donation.nonprofit_id,
        donation_nonprofit_name: donation.nonprofit&.name,
        supporter_id: donation.supporter_id,
        supporter_name: donation.supporter&.name,
        supporter_nonprofit_id: donation.supporter&.nonprofit_id,
        supporter_nonprofit_name: donation.supporter&.nonprofit&.name,
        payment_id: donation.payment_id,
        payment_supporter_id: donation.payment&.supporter_id,
        donation_date: donation.created_at,
        donation_card_stripe_id: donation.card&.stripe_customer_id,
        donation_card_holder: donation.card&.holder_id,
        donation_campaign_id: donation.campaign_id,
        donation_campaign_exists: !donation.campaign.nil?,
        donation_campaign_gift: donation.campaign_gifts.map { |i| i.id }.join(", "),
        donation_recurring_donation_active: donation.recurring_donation&.active,
        donation_recurring_donation_failures: donation.recurring_donation&.n_failures,
        errors: d[:issues]
      }
    }
  end

  def self.has_no_supporter(t)
    if !t[:donation].supporter
      t[:issues].push(:no_supporter)
    end
  end

  def self.has_no_nonprofit(t)
    if !t[:donation].nonprofit
      t[:issues].push(:no_nonprofit)
    end
  end

  def self.first_level(d)
    has_no_nonprofit(d)
    has_no_supporter(d)
  end

  def self.donation_and_supporter_no_match(t)
    if t[:donation].nonprofit != t[:donation].supporter&.nonprofit
      t[:issues].push(:donation_and_supporter_nps_dont_match)
    end
  end

  def self.payment_and_supporter_no_match(t)
    if t[:donation].payment && (t[:donation].payment&.supporter != t[:donation].supporter)
      t[:issues].push(:payment_and_donation_supporter_no_match)
    end
  end

  def self.second_level(donation)
    donation_and_supporter_no_match(donation)
    payment_and_supporter_no_match(donation)
  end

  # some donations have invalid records. Clean them up.
  def self.cleanup(invalid_donations)
    Qx.transaction do
      invalid_donations.each do |d|
        if d[:issues].include?(:no_supporter)
          cleanup_for_no_supporter(d[:donation])
        end

        if d[:issues].include?(:donation_and_supporter_nps_dont_match)
          cleanup_for_donation_and_supporter_nps_dont_match(d[:donation])
        end

        if d[:issues].include?(:no_nonprofit)
          cleanup_for_no_nonprofit(d[:donation])
        end
      end
    end
  end

  def self.cleanup_for_no_supporter(donation)
    np = donation.nonprofit
    if np && !Supporter.exists?(donation.supporter_id)
      if donation.payment&.supporter && donation.payment.supporter.nonprofit == np
        donation.supporter = donation.payment.supporter
        donation.save!
      elsif !donation.payment&.supporter

        supporter = np.supporters.build
        supporter.deleted = true
        if donation.supporter_id
          supporter.id = donation.supporter_id
        end
        supporter.save!

        if !donation.supporter_id
          donation.supporter = supporter
          donation.save!
        end
      end
    end
  end

  def self.cleanup_for_no_nonprofit(donation)
    if !donation.nonprofit && !donation.supporter && !donation.recurring_donation && !donation.campaign && (!donation.payment || !donation.payment.nonprofit) && donation.campaign_gifts.none? && donation.activities.none?
      if donation.payment
        donation.payment.destroy
      end
      donation.destroy
    end
  end

  def self.cleanup_for_donation_and_supporter_nps_dont_match(donation)
    if !donation.supporter.nonprofit && donation.nonprofit
      donation.supporter.nonprofit = donation.nonprofit
      donation.supporter.save!
    end
  end

  def self.delete_donation_fully(donation)
    if donation.campaign_gifts.any?
      donation.campaign_gifts.destroy_all
    end

    donation.card.destroy
    donation.recurring_donation&.destroy
    donation.destroy
  end

  def self.change_all_donation_to_supporter(d, new_supporter)
    d.supporter = new_supporter
    d.save!

    d.activities&.each { |i|
      i.supporter = new_supporter
      i.save!
    }
    d.payments&.each { |i|
      i.supporter = new_supporter
      i.save!
    }

    d.charges&.each { |i|
      i.supporter = new_supporter
      i.save!
    }
    if d.card
      d.card.charges.any? { |c| !d.charges.include?(c) }
      d.card.holder = new_supporter
      d.card.save!
    end

    if d.recurring_donation
      d.recurring_donation.supporter = new_supporter
      d.recurring_donation.save!
    end
  end

  def self.create_new_supporter_on_correct_np(nonprofit, old_supporter)
    supporter = nonprofit.supporters.build
    supporter.name = old_supporter.name
    supporter.email = old_supporter.email
    supporter.phone = old_supporter.phone
    supporter.organization = old_supporter.organization
    supporter.address = old_supporter.address
    supporter.city = old_supporter.city
    supporter.state_code = old_supporter.state_code
    supporter.zip_code = old_supporter.zip_code
    supporter.country = old_supporter.country
    supporter.deleted = true
    supporter.save!
    supporter
  end
end
