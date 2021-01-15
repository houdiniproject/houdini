# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/License

# The attachment_type for SupporterNote activities is wrong. This code fixes that
class FixTypoInActivityAttachmentType < ActiveRecord::Migration[6.1]
  def up
    Activity.connection.execute("UPDATE activities SET attachment_type = 'SupporterNote' WHERE (kind = 'SupporterNote' AND attachment_type != 'SupporterNote')")
  end
end
