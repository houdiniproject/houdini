require 'param_validation'
require 'qx'

module InsertSupporterNotes
  def self.create(notes)
    ParamValidation.new(notes, {
      root: { array_of_hashes: {
        supporter_id: {required: true, is_integer: true},
        user_id: {required: true, is_integer: true},
        content: {required: true}
      } }
    })
    inserted = Qx.insert_into(:supporter_notes)
      .values(notes)
      .timestamps
      .returning('*')
      .execute
    InsertActivities.for_supporter_notes(inserted.map{|h| h['id']})
    return inserted
  end
end
