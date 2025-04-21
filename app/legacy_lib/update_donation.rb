# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
module UpdateDonation
  def self.from_followup(donation, params)
    donation.designation = params[:designation] if params[:designation].present?
    donation.dedication = params[:dedication] if params[:dedication].present?
    donation.comment = params[:comment] if params[:comment].present?
    donation.save
    donation
  end

  # @param [Integer] donation_id the donation for the payment you wish to modify
  def self.update_payment(donation_id, data)
    ParamValidation.new({id: donation_id, data: data},
      id: {required: true, is_reference: true},
      data: {required: true, is_hash: true})
    existing_payment = Payment.where("donation_id = ?", donation_id).last

    unless existing_payment
      raise ParamValidation::ValidationError.new("#{donation_id} is does not correspond to a valid donation",
        key: :id)
    end

    is_offsite = !existing_payment.offsite_payment.nil?

    validations = {
      designation: {is_a: String},
      dedication: {is_a: String},
      comment: {is_a: String},
      campaign_id: {is_reference: true, required: true},
      event_id: {is_reference: true, required: true}
    }

    if is_offsite
      # if offline test the other values (fee_total, gross_amount, check_number, date)
      #
      validations.merge!(gross_amount: {is_integer: true, min: 1},
        fee_total: {is_integer: true},
        check_number: {is_a: String},
        date: {can_be_date: true})
    end

    ParamValidation.new(data, validations)
    set_to_nil = {campaign: data[:campaign_id] == "", event: data[:event_id] == ""}

    # validate campaign and event ids if there and if they belong to nonprofit
    if set_to_nil[:campaign]
      campaign = nil
    else
      campaign = Campaign.where("id = ?", data[:campaign_id]).first
      unless campaign
        raise ParamValidation::ValidationError.new("#{data[:campaign_id]} is not a valid campaign", key: :campaign_id)
      end
      unless campaign.nonprofit == existing_payment.nonprofit
        raise ParamValidation::ValidationError.new("#{data[:campaign_id]} campaign does not belong to this nonprofit for payment #{existing_payment.id}", key: :campaign_id)
      end
    end

    if set_to_nil[:event]
      event = nil
    else
      event = Event.where("id = ?", data[:event_id]).first
      unless event
        raise ParamValidation::ValidationError.new("#{data[:event_id]} is not a valid event", key: :event_id)
      end
      unless event.nonprofit == existing_payment.nonprofit
        raise ParamValidation::ValidationError.new("#{data[:event_id]} event does not belong to this nonprofit for payment #{existing_payment.id}", key: :event_id)
      end
    end

    donation = existing_payment.donation
    ret = donation.attributes
    Qx.transaction do
      donation.designation = data[:designation] if data[:designation]
      donation.comment = data[:comment] if data[:comment]
      donation.dedication = data[:dedication] if data[:dedication]
      donation.event = event if event
      donation.event = nil if data[:event_id] == ""
      donation.campaign = campaign if campaign
      donation.campaign = nil if data[:campaign_id] == ""

      if is_offsite
        donation.amount = data[:gross_amount] if data[:gross_amount]
        donation.date = data[:date] if data[:date]
      end

      modern_donation = donation.modern_donations.first
      trx = modern_donation.trx
      # edits_to_payments
      if is_offsite
        # if offline, set date, gross_amount, fee_total, net_amount
        existing_payment.towards = data[:designation] if data[:designation]
        existing_payment.date = data[:date] if data[:date]
        existing_payment.gross_amount = data[:gross_amount] if data[:gross_amount]
        existing_payment.fee_total = data[:fee_total] if data[:fee_total]
        existing_payment.net_amount = existing_payment.gross_amount - existing_payment.fee_total

        if existing_payment.changed?
          existing_payment.save!
          if existing_payment.previous_changes.has_key? "gross_amount"
            modern_donation.amount = existing_payment.gross_amount
            trx.amount = existing_payment.gross_amount
          end
        end
      elsif donation.designation
        Payment.where("donation_id = ?", donation.id).update_all(towards: donation.designation, updated_at: Time.now)
      end

      # if offsite, set check_number, date, gross_amount
      if is_offsite
        offsite_payment = existing_payment.offsite_payment
        offsite_payment.check_number = data[:check_number] if data[:check_number]
        offsite_payment.date = data[:date] if data[:date]
        offsite_payment.gross_amount = data[:gross_amount] if data[:gross_amount]

        offsite_payment.save! if offsite_payment.changed?
      end
      trx.save! if trx.changed?
      donation.save! if donation.changed?
      md_changed = modern_donation.changed?
      modern_donation.save! if modern_donation.changed?
      if ["dedication", "designation"].any? { |i| donation.previous_changes.has_key? i } || md_changed
        modern_donation.publish_updated
      end

      existing_payment.reload

      ret = donation.attributes
      ret[:payment] = existing_payment.attributes
      ret[:offsite_payment] = offsite_payment.attributes if is_offsite
    end
    ret
  end
end
