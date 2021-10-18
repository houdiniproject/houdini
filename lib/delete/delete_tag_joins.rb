# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require 'qx'

module DeleteTagJoins
  @columns = %w[id created_at updated_at metadata tag_definition_id supporter_id]
  def self.find_multiple_tag_joins
    qx_results = Qx.select("CONCAT(tag_joins.supporter_id, '_', tag_joins.tag_definition_id) AS our_concat, COUNT(id) AS our_count")
                   .from(:tag_joins)
                   .group_by('our_concat')
                   .having('COUNT(id) > 1')
                   .execute

    tag_joins_from_qx = TagJoin.where("CONCAT(supporter_id, '_', tag_definition_id) IN (?)", qx_results.map { |i| i['our_concat'] }).select('id, tag_definition_id, supporter_id, created_at')
    grouped_tagged_joins = tag_joins_from_qx.group_by { |tj| "#{tj.supporter_id}_#{tj.tag_definition_id}" }

    ids_to_delete = []
    grouped_tagged_joins.each do |_, v|
      sorted = v.sort_by(&:created_at).to_a
      ids_to_delete += sorted.map(&:id)[0, sorted.count - 1]
    end

    ids_to_delete
  end

  def self.copy_and_delete(ids_to_delete)
    if ids_to_delete.any?

      # select_query = Qx.select(@columns).from(:tag_joins).where('id IN ($ids)', ids:ids_to_delete).parse

      Qx.insert_into(:tag_joins_backup, @columns).select(@columns).from(:tag_joins).where('id IN ($ids)', ids: ids_to_delete).execute
      # Qx.execute_raw("INSERT INTO tag_joins_backup ('id', '' #{select_query}")
      TagJoin.where('id IN (?)', ids_to_delete).delete_all
    end
  end

  def self.revert
    Qx.insert_into(:tag_joins, @columns).select(@columns).from(:tag_joins_backup).execute
    # Qx.execute_raw("INSERT INTO tag_joins SELECT * FROM tag_joins_backup")
    Qx.execute_raw('DELETE FROM tag_joins_backup')
  end
end
