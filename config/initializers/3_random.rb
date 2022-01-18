
# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
if RUBY_VERSION < '2.5.0'
  # in Ruby 2.5, Random.raw_seed was renamed Random.urandom. So we need that to
  # run securerandom gem
  class Random
    def self.urandom(size)
      self.raw_seed(size)
    end
  end
  
else
  puts "Monkeypatch for Random.urandom no longer needed"
end
