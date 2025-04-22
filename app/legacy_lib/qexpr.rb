# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
# A module that allows you to construct complex SQL expressions by piecing
# together methods in ruby.
#
# Uses Immutable data structures
#
# Goals:
#  - composability and reusability of sql fragments
#  - pretty printing of sql with formatting and color

require "immutable"
require "colorize"

class Qexpr
  attr_accessor :tree

  def initialize(h = nil)
    @tree = Immutable::Hash[h]
  end

  def to_s
    parse
  end

  # Parse an qexpr object into a sql string expression
  def parse
    expr = ""
    if @tree[:withs]&.any?
      expr += "WITH ".bold.light_blue + @tree[:withs].join(",\n") + "\n"
    end

    if @tree[:insert]
      expr = "#{@tree[:insert]} #{@tree[:values].blue}"
      expr += "\nRETURNING ".bold.light_blue + (@tree[:returning] || ["id"]).join(", ").blue
      return expr
    end
    query_based_expression = @tree[:update] || @tree[:delete_from] || @tree[:select]
    # Query-based expessions

    if query_based_expression.nil? || query_based_expression.empty?
      raise ArgumentError.new("Must have a select, update, or delete clause")
    end

    expr += query_based_expression

    if @tree[:from]
      expr += "\nFROM".bold.light_blue + @tree[:from].map do |f|
        f.is_a?(String) ? f : " (#{f[:sub_expr].parse}\n) AS #{f[:as]}"
      end.join(", ").blue
    end
    expr += @tree[:joins].join(" ") if @tree[:joins]
    expr += @tree[:where] if @tree[:where]
    expr += @tree[:group_by] if @tree[:group_by]
    expr += @tree[:having] if @tree[:having]
    expr += @tree[:order_by] if @tree[:order_by]
    expr += @tree[:limit] if @tree[:limit]
    expr += @tree[:offset] if @tree[:offset]

    if @tree[:select] && @tree[:as]
      expr = "(#{expr}) AS #{@tree[:as]}"
    end
    if @tree[:update] && @tree[:returning]
      expr += "\nRETURNING ".bold.light_blue + @tree[:returning].join(", ").blue
    end
    expr
  end

  # insert into table_name the values from every hash inside of arr
  # optionally pass in:
  # no_timestamps: don't set created_at and updated_at
  # common_data: a hash of data to set for all rows
  # returning: what columns to return
  def insert(table_name, arr, options = {})
    arr = [arr] if arr.is_a? Hash
    arr = arr.map { |h| h.sort.to_h } # Make sure all key/vals are ordered the same way
    keys = arr.first.keys
    keys = keys.concat(options[:common_data].keys) if options[:common_data]
    keys = keys.map { |k| "\"#{k}\"" }.join(", ")
    ts_columns = options[:no_timestamps] ? "" : "created_at, updated_at, "
    ts_values = options[:no_timestamps] ? "" : "#{Qexpr.now}, #{Qexpr.now}, "
    common_vals = options[:common_data] ? options[:common_data].values.map { |v| Qexpr.quote(v) } : []
    vals = arr.map { |h| "(" + ts_values + h.values.map { |v| Qexpr.quote(v) }.concat(common_vals).join(",") + ")" }.join(",")
    Qexpr.new @tree
      .put(:insert, "INSERT INTO".bold.light_blue + " #{table_name} (#{ts_columns} #{keys})".blue)
      .put(:values, "\nVALUES".bold.light_blue + " #{vals}".blue)
  end

  def update(table_name, settings, os = {})
    Qexpr.new @tree.put(:update, "UPDATE".bold.light_blue + " #{table_name}".blue + "\nSET".bold.light_blue + " #{settings.map { |key, val| "#{key}=#{Qexpr.quote(val)}" }.join(", ")}".blue)
  end

  def delete_from(table_name)
    Qexpr.new @tree.put(:delete_from, "DELETE FROM".bold.light_blue + " #{table_name}".blue)
  end

  # Create or append select columns
  def select(*cols)
    if @tree[:select]
      Qexpr.new @tree.put(:select, @tree[:select] + ", #{cols.join(", ")}".blue)
    else
      cols = if cols.count < 4
        " #{cols.join(", ")}"
      else
        "\n  #{cols.join("\n, ")}"
      end
      Qexpr.new @tree.put(:select, "\nSELECT".bold.light_blue + "#{cols}".blue)
    end
  end

  def select_distinct(*cols)
    Qexpr.new @tree.put(:select, "\nSELECT DISTINCT".bold.light_blue + "\n  #{cols.join("\n, ")}".blue)
  end

  def select_distinct_on(cols_distinct, cols_select)
    Qexpr.new @tree.put(:select, "SELECT DISTINCT ON".bold.light_blue + " (#{Array(cols_distinct).join(", ")})\n  #{Array(cols_select).join("\n, ")}".blue)
  end

  def from(expr, as = nil)
    Qexpr.new @tree.put(:from, (@tree[:from] || Immutable::Vector[]).add(Qexpr.from_expr(expr, as)))
  end

  def group_by(*cols)
    Qexpr.new @tree.put(:group_by, "\nGROUP BY".bold.light_blue + " #{cols.join(", ")}".blue)
  end

  def order_by(expr)
    Qexpr.new @tree.put(:order_by, "\nORDER BY".bold.light_blue + " #{expr}".blue)
  end

  def limit(i)
    Qexpr.new @tree.put(:limit, "\nLIMIT".bold.light_blue + " #{i.to_i}".blue)
  end

  def offset(i)
    Qexpr.new @tree.put(:offset, "\nOFFSET".bold.light_blue + " #{i.to_i}".blue)
  end

  def with(name, expr, materialized: nil)
    materialized_text = if !materialized.nil?
      materialized ? "MATERIALIZED" : "NOT MATERIALIZED"
    else
      ""
    end
    Qexpr.new(
      @tree.put(:withs,
        (@tree[:withs] || Immutable::Vector[]).add(name.to_s.blue + " AS #{materialized_text} (\n  ".bold.light_blue + "   #{expr.is_a?(String) ? expr : expr.parse}".blue + "\n)".bold.light_blue))
    )
  end

  def join(table_name, on_expr, data = {})
    on_expr = Qexpr.interpolate_expr(on_expr, data)
    Qexpr.new @tree
      .put(:joins, (@tree[:joins] || Immutable::Vector[]).add("\nJOIN".bold.light_blue + " #{table_name}\n  ".blue + "ON".bold.light_blue + " #{on_expr}".blue))
  end

  def inner_join(table_name, on_expr, data = {})
    on_expr = Qexpr.interpolate_expr(on_expr, data)
    Qexpr.new @tree
      .put(:joins, (@tree[:joins] || Immutable::Vector[]).add("\nINNER JOIN".bold.light_blue + " #{table_name}\n  ".blue + "ON".bold.light_blue + " #{on_expr}".blue))
  end

  def left_outer_join(table_name, on_expr, data = {})
    on_expr = Qexpr.interpolate_expr(on_expr, data)
    Qexpr.new @tree
      .put(:joins, (@tree[:joins] || Immutable::Vector[]).add("\nLEFT OUTER JOIN".bold.light_blue + " #{table_name}\n  ".blue + "ON".bold.light_blue + " #{on_expr}".blue))
  end

  def join_lateral(join_name, select_statement, success_condition = true, data = {})
    select_statement = Qexpr.interpolate_expr(select_statement, data)
    Qexpr.new @tree
      .put(:joins, (@tree[:joins] || Immutable::Vector[]).add("\n JOIN LATERAL".bold.light_blue + " (#{select_statement})\n  #{join_name} ".blue + "ON".bold.light_blue + " #{success_condition}".blue))
  end

  def as(name)
    Qexpr.new @tree.put(:as, name)
  end

  def where(expr, data = {})
    expr = Qexpr.interpolate_expr(expr, data)
    if @tree[:where]
      Qexpr.new @tree.put(:where, @tree[:where] + "\nAND".bold.light_blue + "   (#{expr})".blue)
    else
      Qexpr.new @tree.put(:where, "\nWHERE".bold.light_blue + " (#{expr})".blue)
    end
  end

  def returning(*cols)
    Qexpr.new @tree.put(:returning, (@tree[:returning] || Immutable::Vector[]).concat(cols))
  end

  def having(expr, data = {})
    if @tree[:having]
      Qexpr.new @tree.put(:having, @tree[:having] + "\nAND".bold.light_blue + "    (#{Qexpr.interpolate_expr(expr, data)})".blue)
    else
      Qexpr.new @tree.put(:having, "\nHAVING".bold.light_blue + " (#{Qexpr.interpolate_expr(expr, data)})".blue)
    end
  end

  # Merge a Qexpr tree with another to create one single qexpr expression
  def self.merge_with(qexpr)
    Qexpr.new @tree.merge(qexpr.tree)
  end

  # Remove clauses from the expression
  # eg expr.remove(:from, :where)
  def remove(*keys)
    Qexpr.new keys.reduce(@tree) { |tree, key| tree.delete(key) }
  end

  # Quote a string for use in sql to prevent injection or weird errors
  # Always use this for all values!
  # Just uses double-dollar quoting universally. Should be generally safe and easy.
  # Will return an unquoted value it it's a Fixnum
  def self.quote(val)
    if val.is_a?(Integer) || (val.is_a?(String) && val =~ /^\$Q\$.+\$Q\$$/) # is a valid num or already quoted
      val
    elsif val.nil?
      "NULL"
    elsif !!val == val # is a boolean
      val ? "'t'" : "'f'"
    else
      "$Q$" + val.to_s + "$Q$"
    end
  end

  # An alias of PG.quote_ident, for convenience sake
  # Double-quotes sql identifiers
  def self.quote_ident(str)
    str.split(".").map { |s| "\"#{s}\"" }.join(".")
  end

  # sql-quoted datetime value useful for created_at and updated_at columns
  def self.now
    Qexpr.quote(Time.current)
  end

  # Given a max page length and the current page,
  # return the offset value
  # (eg: page_length=30 and page=3, then return 60)
  def self.page_offset(page_length, page = 1)
    page = page.to_i
    page = 1 if page <= 0
    Qexpr.quote((page.to_i - 1) * page_length.to_i)
  end

  # Given the total row count, the max page length, and the current page,
  # return the total results left
  def self.remaining_count(total_count, page_length, current_page = 1)
    return 0 unless current_page
    rem = total_count.to_i - current_page.to_i * page_length.to_i
    rem = 0 if rem < 0
    rem
  end

  # Given a string sql expression with interpolations like "WHERE id > ${id}"
  # and given a hash of key/vals.
  # interpolate the hash data into the expression
  def self.interpolate_expr(expr, data)
    expr.gsub(/\$\w+/) do |match|
      val = data[match.gsub(/[ \$]*/, "").to_sym]
      if val.is_a?(Array) || val.is_a?(Immutable::Vector)
        val.to_a.map { |x| Qexpr.quote(x) }.join(", ")
      else
        Qexpr.quote val
      end
    end
  end

  private

  # Given some kind of expr object (might be just a string or another whole Qexpr expr), and an 'as' value
  # then give back either a hash for the sub-Qexpr expression, or just a string.
  # #parse will deal with the from string/hash
  def self.from_expr(expr, as)
    if expr.is_a?(Qexpr)
      Immutable::Hash[sub_expr: expr, as: as]
    else
      " #{expr} #{as ? "AS #{as}" : ""}"
    end
  end
end
