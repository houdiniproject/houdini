# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class StripeAccount < ApplicationRecord
  attr_accessible :object, :stripe_account_id
  has_one :nonprofit, primary_key: :stripe_account_id
  has_one :nonprofit_verification_process_status, primary_key: :stripe_account_id

  ## this scopes let you find accounts that do or do not have a future_requirements attribute
  scope :with_future_requirements, -> { where("object->'future_requirements' IS NOT NULL") }
  scope :without_future_requirements, -> { where("object->'future_requirements' IS NULL") }

  def object=(input)
    serialize_on_update(input)
  end

  def verification_status
    if pending_verification.any?
      :pending
    elsif needs_immediate_validation_info
      :unverified
    elsif needs_more_validation_info
      :temporarily_verified
    else
      :verified
    end
  end

  def requirements
    Requirements.new(object["requirements"])
  end

  def future_requirements
    Requirements.new(object["future_requirements"] || {})
  end

  # the distinct union of the current pending_verification and the future pending_verification values
  def pending_verification
    (requirements.pending_verification + future_requirements.pending_verification).uniq
  end

  # describes a deadline where additional requirements are needed to be completed
  # future_requirements can have a current_deadline and not have any additional requirements so
  # we don't consider that a deadline here.
  def deadline
    deadlines = []
    if requirements.current_deadline
      deadlines.push(requirements.current_deadline)
    end
    if future_requirements.current_deadline && future_requirements.any_requirements_other_than_external_account?(
      include_eventually_due: true, include_pending_verification: true
    )
      deadlines.push(future_requirements.current_deadline)
    end

    deadlines.min
  end

  # these are validation requirements which may come in the future but haven't yet
  def needs_more_validation_info
    requirements.any_requirements_other_than_external_account?(include_eventually_due: true)
  end

  # these are validation requirements which must be done by a given deadline
  def needs_immediate_validation_info
    deadline || requirements.any_requirements_other_than_external_account?
  end

  def retrieve_from_stripe
    Stripe::Account.retrieve(stripe_account_id, {stripe_version: "2020-08-27"})
  end

  def update_from_stripe
    update(object: retrieve_from_stripe)
  end

  private

  def serialize_on_update(input)
    object_json = nil

    case input
    when Stripe::Account
      write_attribute(:object, input.to_hash)
      object_json = object
      puts object
    when String
      write_attribute(:object, input)
      object_json = object
    end
    self.charges_enabled = !!object_json["charges_enabled"]
    self.payouts_enabled = !!object_json["payouts_enabled"]
    requirements = Requirements.new(object_json["requirements"])
    self.disabled_reason = requirements.disabled_reason
    self.currently_due = requirements.currently_due
    self.past_due = requirements.past_due
    self.eventually_due = requirements.eventually_due
    self.pending_verification = requirements.pending_verification

    unless stripe_account_id
      self.stripe_account_id = object_json["id"]
    end

    object
  end

  # describes the Stripe Account Requirements in a more pleasant way
  class Requirements
    def initialize(requirements)
      @requirements = requirements || {}
    end

    def current_deadline
      if @requirements["current_deadline"] && @requirements["current_deadline"].to_i != 0
        Time.at(@requirements["current_deadline"].to_i)
      end
    end

    def disabled_reason
      @requirements["disabled_reason"]
    end

    def currently_due
      @requirements["currently_due"] || []
    end

    def past_due
      @requirements["past_due"] || []
    end

    def eventually_due
      @requirements["eventually_due"] || []
    end

    def any_requirements_other_than_external_account?(opts = {})
      defaults = {
        include_eventually_due: false,
        include_pending_verification: false
      }

      opts = defaults.merge(opts)
      requirement_arrays = [past_due, currently_due]
      if opts[:include_eventually_due]
        requirement_arrays.push(eventually_due)
      end

      if opts[:include_pending_verification]
        requirement_arrays.push(pending_verification)
      end

      requirement_arrays.any? do |i|
        !i.none? && !i.all? do |j|
          j.starts_with?("external_account")
        end
      end
    end

    def pending_verification
      @requirements["pending_verification"] || []
    end
  end
end
