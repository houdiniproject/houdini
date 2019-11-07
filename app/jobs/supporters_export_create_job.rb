class SupportersExportCreateJob < ApplicationJob
  queue_as :default

  def perform(*args)
    ExportSupporters.run_export(*args)
  end
end
