# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class NotEnoughQuantityError < HoudiniError
  attr_accessor :klass, :id, :requested
  def initialize(klass, id, requested, msg)
    @klass = klass
    @id = id
    @requested = requested
    super(msg)
  end
end
