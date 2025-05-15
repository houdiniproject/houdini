# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "qx"

module UpdateOrder
  # data is an array of hashes of:
  #  - id : id of row to update
  #  - order: new order of row to update
  def self.with_data(table_name, data)
    vals = data.map { |h| "(#{h[:id].to_i}, #{h[:order].to_i})" }.join(", ")
    from_str = "(VALUES #{vals}) AS data(id, \"order\")"
    Qx.update("#{table_name}")
      .set('"order"="data"."order"')
      .timestamps
      .from(from_str)
      .where("data.id=#{table_name}.id")
      .returning("#{table_name}.order", "#{table_name}.id")
      .execute
  end
end
