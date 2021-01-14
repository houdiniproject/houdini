# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE

module InsertSupporterNotes
  #note_supporter_users : array of hashes
  # each hash:
  #   supporter: Supporter new note should belong to
  #   user: User creating the note
  #   note: parameters to pass into the note
  def self.create(*note_supporter_users)
    inserted = nil
    ActiveRecord::Base.transaction do 
      inserted = note_supporter_users.map do |nsu|
        nsu[:supporter].supporter_notes.create(nsu[:note].merge({user: nsu[:user]}))
      end
      InsertActivities.for_supporter_notes(inserted)
    end
    inserted
  end
end
