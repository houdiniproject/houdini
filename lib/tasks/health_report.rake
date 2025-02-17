# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
desc "For sending an activity report email of what has been happening on the system"

# Clear old activerecord sessions tables daily
task send_health_report: :environment do
  GenericMailer.admin_notice(
    body: HealthReport.format_data(HealthReport.query_data),
    subject: "CommitChange activity report #{Format::Date.to_readable(Time.now)}"
  ).deliver_later
end
