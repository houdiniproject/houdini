
SUO_DALLI_CLIENT = Dalli::Client.new(nil, { :namespace => "locks_v1", :compress => true })

  
class DistributedLock
  DEFAULT_OPTIONS = {
    acquisition_timeout: 30.seconds,
    acquisition_delay: 0.01,
    stale_lock_expiration: 1.minute,
    resources: 1,
    ttl: 5,
  }.freeze

  attr_accessor :client

  def initialize(key, options= {})
    @options = DEFAULT_OPTIONS.merge(options)
    @client = Suo::Client::Memcached.new(key, client:SUO_DALLI_CLIENT, **@options)
  end

  def with_lock()
    token = @client.lock
    raise LockAcquisitionError unless token
    begin
      yield
    ensure
      unlock(token)
    end
  end

  def lock()
    token = @client.lock
    raise LockAcquisitionError unless token
    token
  end

  def unlock(token)
    @client.unlock(token)
  end
end

class LockAcquisitionError < RuntimeError
end
