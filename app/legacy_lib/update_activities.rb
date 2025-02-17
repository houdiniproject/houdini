# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE

module UpdateActivities
  def self.for_supporter_notes(supporter_note)
    user_email = supporter_note.user.email
    supporter_note.activities.update_all(json_data: {content: supporter_note.content, user_email: user_email}.to_json,
      updated_at: DateTime.now)
  end
end
