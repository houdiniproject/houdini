# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
require 'parallel'

module ParallelAr
  def self.reduce(arr, accum, &block)
    Parallel.each(arr, in_threads: 8) do |elem|
      ActiveRecord::Base.connection_pool.with_connection do
        ActiveRecord::Base.transaction do
          accum = block.call(accum, elem)
        end
      end
    end
    accum
  end
end
