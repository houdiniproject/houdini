# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
json.call(supporter_note, :id, :content, :deleted)

json.object "supporter_note"

json.url api_nonprofit_supporter_supporter_note_url(
  supporter_note.nonprofit,
  supporter_note.supporter,
  supporter_note
)

json.nonprofit supporter_note.nonprofit.id

json.supporter supporter_note.supporter.id

json.user supporter_note.user.id
