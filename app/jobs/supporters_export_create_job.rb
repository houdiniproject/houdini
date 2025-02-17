class SupportersExportCreateJob < EmailJob
  def perform(*args)
    ExportSupporters.run_export(*args)
  end
end
