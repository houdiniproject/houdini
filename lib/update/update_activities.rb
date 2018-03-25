require 'qx'

module UpdateActivities

  def self.for_supporter_notes(note)

    user_email = Qx.select('email')
          .from(:users)
          .where(id: note[:user_id])
          .execute
          .first['email'] 

    Qx.update(:activities)
      .set(json_data: {content: note[:content], user_email: user_email}.to_json)
      .timestamps
      .where(attachment_id: note[:id])
      .execute

  end 
end

