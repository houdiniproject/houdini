# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
module UpdateSupporterNotes
  # should this get put into a callback on SupporterNote? Probably but
  # not sure how right now.
  def self.update(supporter_note, params)
    ActiveRecord::Base.transaction do
      supporter_note.update params
      supporter_note.save!
      UpdateActivities.for_supporter_notes(note)
    end
  end

  # sets the deleted column to true on supporter_notes (soft delete)
  # and then does a hard delete on the associated activity
  #
  # should this get put into a callback on SupporterNote? Probably but
  # not sure how right now.
  def self.delete(supporter_note)
    ActiveRecord::Base.transaction do
      supporter_note.discard!
      supporter_note.activities.destroy_all
    end
  end
end
