ENV['TZ'] = 'UTC'
Time.zone = 'UTC'

module Chronic
  def self.time_class
    ::Time.zone
  end
end
