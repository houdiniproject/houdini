class PaymentExportCreateJob < ApplicationJob
  queue_as :default

  def perform(npo_id, params, user_id, export_id)
    ExportPayments.run_export(npo_id, params, user_id, export_id)
  end
end
