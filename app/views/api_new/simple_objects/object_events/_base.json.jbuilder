# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE

json.partial! event_entity, as: :object, __expand: build_json_expansion_path_tree("parent")
