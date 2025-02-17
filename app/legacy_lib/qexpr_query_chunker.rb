# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
# TODO combine these two items

module QexprQueryChunker
  # Used to get a chunk of a Qexpr query
  # @param [Integer] offset the offset for the beginning of the chunk
  # @param [Integer] limit the maximum number of rows to get in the chunk
  # @param [Boolean] skip_header whether you should skip the header row in the returned output. Defaults to false
  # @yieldreturn [Qexpr] a block which, when called, returns the main Qexpr query
  # @return [Enumerator<Array>] an Enumerator, with each item an array for a row
  def self.get_chunk_of_query(offset = nil, limit = nil, skip_header = false, &block)
    Enumerator.new do |y|
      expr = block.call
      expr = expr.offset(offset) if offset

      expr = expr.limit(limit) if limit
      vecs = Psql.execute_vectors(expr.parse)

      y << vecs.first.to_a.map { |k| k.to_s.titleize } unless skip_header

      vecs.drop(1).each { |v| y << v.to_a }
    end
  end

  # Get a lazy enumerable getting a query in chunks. block is a block used for creating a query for a new chunk

  # @param [Integer] chunk_limit the size of a chunk. Defaults to 35000 rows
  # @yieldparam [Integer] offset the offset for the beginning of the chunk
  # @yieldparam [Integer] limit the maximum number of rows to get in the chunk
  # @yieldparam [Boolean] skip_header whether you should skip the header row in the returned output.
  # @yieldreturn [Enumerator<Array>] an Enumerator, with each item an array for a row
  # @return [Enumerator::Lazy] a lazy enumerator for getting every item in the query
  def self.for_export_enumerable(chunk_limit = 35_000, &block)
    Enumerator.new do |y|
      last_export_length = 0
      limit = chunk_limit
      page = 0
      while page == 0 || last_export_length == limit
        # either we haven't started yet or the last export == limit (since if it didn't we're to the end)
        page += 1
        offset = Qexpr.page_offset(limit, page)
        export_returned = block.call(offset, limit, page > 1).to_a
        # we got the titles too if on_first, let's skip one row
        last_export_length = (page == 1) ? export_returned.length - 1 : export_returned.length
        # efficient? no. Do we care? eh.
        export_returned.each do |i|
          y << i
        end
      end
    end.lazy
  end
end
