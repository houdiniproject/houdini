# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE

module UpdateOrder
  # data is an array of hashes of:
  #  - id : id of row to update
  #  - order: new order of row to update
  def self.with_data(table_name, data)
    vals = data.map { |h| "(#{h[:id].to_i}, #{h[:order].to_i})" }.join(", ")
    from_str = "(VALUES #{vals}) AS data(id, \"order\")"
    Qx.update(table_name.to_s)
      .set('"order"="data"."order"')
      .timestamps
      .from(from_str)
      .where("data.id=#{table_name}.id")
      .returning("#{table_name}.order", "#{table_name}.id")
      .execute
  end
end
