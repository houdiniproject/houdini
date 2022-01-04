# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class NotEnoughQuantityError < HoudiniError
  attr_accessor :klass, :id, :requested
  def initialize(klass, id, requested, msg)
    @klass = klass
    @id = id
    @requested = requested
    super(msg)
  end
end
