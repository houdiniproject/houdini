# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later

module UpdateSupporterNotes
  def self.update(note)
    Qx.update(:supporter_notes)
      .set(content: note[:content], user_id: note[:user_id])
      .timestamps
      .where(id: note[:id])
      .execute
    UpdateActivities.for_supporter_notes(note)
  end

  # sets the deleted column to true on supporter_notes (soft delete)
  # and then does a hard delete on the associated activity
  def self.delete(id)
    Qx.update(:supporter_notes)
      .set(deleted: true)
      .where(id: id)
      .execute
    Qx.delete_from(:activities).where(attachment_id: id).execute
  end
end
