# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
module CreateCampaignGift
  # @param [Hash] params
  #     * campaign_gift_option_id
  #      * donation_id
  def self.create(params)
    ParamValidation.new(params,
      campaign_gift_option_id: {
        required: true,
        is_integer: true
      },
      donation_id: {
        required: true,
        is_integer: true
      })

    donation = Donation.includes(:nonprofit).includes(:supporter).includes(:recurring_donation).includes(:campaign_gifts).where("id = ?", params[:donation_id]).first
    unless donation
      raise ParamValidation::ValidationError.new("#{params[:donation_id]} is not a valid donation id.", key: :donation_id)
    end

    campaign_gift_option = CampaignGiftOption.includes(:campaign).where("id = ?", params[:campaign_gift_option_id]).first
    unless campaign_gift_option
      raise ParamValidation::ValidationError.new("#{params[:campaign_gift_option_id]} is not a valid campaign gift option", key: :campaign_gift_option_id)
    end

    # does donation already have a campaign_gift
    if donation.campaign_gifts.any?
      raise ParamValidation::ValidationError.new("#{params[:donation_id]} already has at least one associated campaign gift", key: :donation_id)
    end

    if donation.campaign != campaign_gift_option.campaign
      raise ParamValidation::ValidationError.new("#{params[:campaign_gift_option_id]} is not for the same campaign as donation #{params[:donation_id]}", key: :campaign_gift_option_id)
    end

    if !donation.recurring_donation.nil? && !campaign_gift_option.amount_recurring.nil? && campaign_gift_option.amount_recurring > 0
      # it's a recurring_donation. Is it enough? for the gift level?
      unless donation.recurring_donation.amount == campaign_gift_option.amount_recurring
        AdminFailedGiftJob.perform_later(donation, campaign_gift_option)
        raise ParamValidation::ValidationError.new("#{params[:campaign_gift_option_id]} gift options requires a recurring donation of #{campaign_gift_option.amount_recurring} for donation #{donation.id}", key: :campaign_gift_option_id)
      end
    else
      unless donation.amount == campaign_gift_option.amount_one_time
        AdminFailedGiftJob.perform_later(donation, campaign_gift_option)
        raise ParamValidation::ValidationError.new("#{params[:campaign_gift_option_id]} gift options requires a donation of #{campaign_gift_option.amount_one_time} for donation #{donation.id}", key: :campaign_gift_option_id)
      end
    end

    # are any gifts available?
    if campaign_gift_option.quantity.nil? || campaign_gift_option.quantity.zero? || campaign_gift_option.total_gifts < campaign_gift_option.quantity
      gift = CampaignGift.new params
      Qx.transaction do
        gift.save!
      end
      return gift
    end
    AdminFailedGiftJob.perform_later(donation, campaign_gift_option)
    raise ParamValidation::ValidationError.new("#{params[:campaign_gift_option_id]} has no more inventory", key: :campaign_gift_option_id)
  end

  def self.validate_campaign_gift(cg)
    donation = cg.donation
    campaign_gift_option = cg.campaign_gift_option
    if !donation.recurring_donation.nil? && !campaign_gift_option.amount_recurring.nil? && campaign_gift_option.amount_recurring > 0
      # it's a recurring_donation. Is it enough? for the gift level?
      unless donation.recurring_donation.amount == campaign_gift_option.amount_recurring
        raise ParamValidation::ValidationError.new("#{campaign_gift_option.id} gift options requires a recurring donation of at least #{campaign_gift_option.amount_recurring}", key: :campaign_gift_option_id)
      end
    else
      unless donation.amount == campaign_gift_option.amount_one_time
        raise ParamValidation::ValidationError.new("#{campaign_gift_option.id} gift options requires a donation of at least #{campaign_gift_option.amount_one_time}", key: :campaign_gift_option_id)
      end
    end
  end
end
