# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'qx'

module UpdateActivities
  def self.for_supporter_notes(note)
    user_email = Qx.select('email')
                   .from(:users)
                   .where(id: note[:user_id])
                   .execute
                   .first['email']

    Qx.update(:activities)
      .set(json_data: { content: note[:content], user_email: user_email }.to_json)
      .timestamps
      .where(attachment_id: note[:id])
      .execute
  end
end
