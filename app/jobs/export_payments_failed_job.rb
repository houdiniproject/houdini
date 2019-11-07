class ExportPaymentsFailedJob < ApplicationJob
  queue_as :default

  def perform(export)
    ExportMailer.export_payments_failed_notification(export).deliver_now
  end
end
