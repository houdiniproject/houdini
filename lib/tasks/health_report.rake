# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
desc "For sending an activity report email of what has been happening on the system"

# Clear old activerecord sessions tables daily
task send_health_report: :environment do
  GenericMailer.admin_notice({
    body: HealthReport.format_data(HealthReport.query_data),
    subject: "CommitChange activity report #{Format::Date.to_readable(Time.now)}"
  }).deliver
end
