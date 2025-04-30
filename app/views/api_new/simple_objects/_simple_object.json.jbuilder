# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE

json.id object.houid

json.object "simple_object"

handle_expansion(:parent, object.parent, {json: json, as: :object, __expand: __expand})

handle_expansion(:nonprofit, object.nonprofit, {json: json, __expand: __expand})

handle_array_expansion(:friends, object.friends, {json: json, item_as: :object, __expand: __expand}) do |expansion|
  expansion.handle_item_expansion(expansion.item)
end

handle_array_expansion(:friends_without_explicit_call, object.friends, {json: json, item_as: :object, __expand: __expand}) do |expansion|
  expansion.handle_item_expansion
end

handle_array_expansion(:friends_no_block_given, object.friends, {json: json, item_as: :object, __expand: __expand})
