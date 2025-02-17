# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
json.data @supporter_notes, partial: "/api/supporter_notes/supporter_note", as: "supporter_note"

json.current_page @supporter_notes.current_page
json.first_page @supporter_notes.first_page?
json.last_page @supporter_notes.last_page?
json.requested_size @supporter_notes.limit_value
json.total_count @supporter_notes.total_count
