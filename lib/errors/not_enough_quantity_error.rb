class NotEnoughQuantityError < CCOrgError
  attr_accessor :klass, :id, :requested
  def initialize(klass, id, requested, msg)
    @klass = klass
    @id = id
    @requested = requested
    super(msg)
  end
end