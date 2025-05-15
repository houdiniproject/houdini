class LockManager
  DEFAULT_OPTIONS = {
    acquisition_timeout: 30,
    acquisition_delay: 0.1
  }.freeze

  BLANK_STR = "".freeze

  attr_accessor :client, :key, :resources, :options

  def initialize(options = {})
    @options = DEFAULT_OPTIONS.merge(options)
    @retry_count = (@options[:acquisition_timeout] / @options[:acquisition_delay].to_f).ceil
  end

  def self.with_transaction_lock(lock_name, options = {})
    lock = new(options)
    lock_id = Zlib.crc32(lock_name.to_s)
    ActiveRecord::Base.transaction do
      lock.retry_with_timeout do
        if ActiveRecord::Base.connection.execute("SELECT pg_try_advisory_xact_lock(#{lock_id})").values[0][0]
          yield
          break
        end
      end
    end
  end

  def retry_with_timeout
    start = Time.now.to_f
    @retry_count.times do
      elapsed = Time.now.to_f - start
      raise "elapsed of #{elasped} is longer than max timeout of #{@options[:acquisition_timeout]}" if elapsed >= @options[:acquisition_timeout]

      result = yield
      return if result
      sleep(rand(@options[:acquisition_delay] * 1000).to_f / 1000)
    end
    raise LockAcquisitionError
  end
end

class LockAcquisitionError < RuntimeError
end
