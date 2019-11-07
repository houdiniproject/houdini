class ExportPaymentsCompletedJob < ApplicationJob
  queue_as :default

  def perform(export)
    ExportMailer.export_payments_completed_notification(export).deliver_now
  end
end
