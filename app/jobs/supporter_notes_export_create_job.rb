class SupporterNotesExportCreateJob < ApplicationJob
  queue_as :default

  def perform(npo_id, params, user_id, export_id)
    ExportSupporterNotes.run_export(npo_id, params, user_id, export_id)
  end
end
