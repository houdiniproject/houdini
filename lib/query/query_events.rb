# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'qexpr'

module QueryEvents
  def self.name_and_id(npo_id)
    Psql.execute(
      Qexpr.new.select(
        'events.name',
        'events.id'
      )
        .from('events')
        .where('events.nonprofit_id=$id', id: npo_id)
        .where("events.deleted='f' OR events.deleted IS NULL")
        .order_by('events.name ASC')
    )
  end
end
