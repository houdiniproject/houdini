# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class DisputeMailer < BaseMailer
  include ActionView::Helpers::NumberHelper

  default from: "support@commitchange.com", to: "support@commitchange.com"
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.dispute_mailer.created.subject
  #

  def created(dispute)
    @dispute = dispute
    @nonprofit = dispute.nonprofit
    @payment = dispute.original_payment
    @stripe_dispute = dispute.stripe_dispute

    mail subject: t("dispute_mailer.created.subject",
      dispute_id: @stripe_dispute.stripe_dispute_id,
      nonprofit_name: @nonprofit.name,
      evidence_due_date: @stripe_dispute.evidence_due_date)
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.dispute_mailer.funds_withdrawn.subject
  #
  def funds_withdrawn(dispute)
    @dispute = dispute
    @nonprofit = dispute.nonprofit
    @payment = dispute.original_payment
    @stripe_dispute = dispute.stripe_dispute
    @withdrawal_transaction = dispute.dispute_transactions.first

    mail subject: t("dispute_mailer.funds_withdrawn.subject",
      dispute_id: @stripe_dispute.stripe_dispute_id,
      nonprofit_name: @nonprofit.name,
      amount: print_currency(@withdrawal_transaction.payment.net_amount, "$"),
      evidence_due_date: @stripe_dispute.evidence_due_date)
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.dispute_mailer.funds_reinstated.subject
  #
  def funds_reinstated(dispute)
    @dispute = dispute
    @nonprofit = dispute.nonprofit
    @payment = dispute.original_payment
    @stripe_dispute = dispute.stripe_dispute
    @reinstated_transaction = dispute.dispute_transactions.second

    mail subject: t("dispute_mailer.funds_reinstated.subject",
      dispute_id: @stripe_dispute.stripe_dispute_id,
      nonprofit_name: @nonprofit.name,
      amount: print_currency(@reinstated_transaction.payment.net_amount, "$"))
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.dispute_mailer.closed.subject
  #
  def won(dispute)
    @dispute = dispute
    @nonprofit = dispute.nonprofit
    @payment = dispute.original_payment
    @stripe_dispute = dispute.stripe_dispute

    mail subject: t("dispute_mailer.won.subject",
      dispute_id: @stripe_dispute.stripe_dispute_id,
      nonprofit_name: @nonprofit.name)
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.dispute_mailer.lost.subject
  #
  def lost(dispute)
    @dispute = dispute
    @nonprofit = dispute.nonprofit
    @payment = dispute.original_payment
    @stripe_dispute = dispute.stripe_dispute

    mail subject: t("dispute_mailer.lost.subject",
      dispute_id: @stripe_dispute.stripe_dispute_id,
      nonprofit_name: @nonprofit.name)
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.dispute_mailer.updated.subject
  #
  def updated(dispute)
    @dispute = dispute
    @nonprofit = dispute.nonprofit
    @payment = dispute.original_payment
    @stripe_dispute = dispute.stripe_dispute

    mail subject: t("dispute_mailer.updated.subject",
      dispute_id: @stripe_dispute.stripe_dispute_id,
      nonprofit_name: @nonprofit.name,
      evidence_due_date: @stripe_dispute.evidence_due_date)
  end

  private

  ## from application_helper. I don't have time to mess with this.
  def print_currency(cents, unit = "EUR", sign = true)
    dollars = cents.to_f / 100.0
    dollars = number_to_currency(dollars, unit: "#{unit}", precision: (dollars.round == dollars) ? 0 : 2)
    dollars = dollars[1..-1] if !sign
    dollars
  end
end
