# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
json.array! @supporter_notes, partial: '/api/supporter_notes/supporter_note', as: 'supporter_note'
