require 'active_record'
require 'colorize'

class Qx
  ##
  # Initialize the database connection using a database url
  # Running this is required for #execute to work
  # Pass in a hash. For now, it only takes on key called :database_url
  # Include the full url including userpass and database name
  # For example:
  # Qx.config(database_url: 'postgres://admin:password@localhost/database_name')
  @@type_map = nil
  def self.config(h)
    @@type_map = h[:type_map]
  end

  # Qx.new, only used internally
  def initialize(tree)
    @tree = tree
    self
  end

  def self.transaction(&block)
    ActiveRecord::Base.transaction do
      yield block
    end
  end

  def self.parse_select(expr)
    str = 'SELECT'
    if expr[:DISTINCT_ON]
      str += " DISTINCT ON (#{expr[:DISTINCT_ON].map(&:to_s).join(', ')})"
    elsif expr[:DISTINCT]
      str += ' DISTINCT'
    end
    str += ' ' + expr[:SELECT].map { |expr| expr.is_a?(Qx) ? expr.parse : expr }.join(', ')
    throw ArgumentError.new('FROM clause is missing for SELECT') unless expr[:FROM]
    str += ' FROM ' + expr[:FROM]
    str += expr[:JOIN].map { |from, cond| " JOIN #{from} ON #{cond}" }.join if expr[:JOIN]
    str += expr[:LEFT_JOIN].map { |from, cond| " LEFT JOIN #{from} ON #{cond}" }.join if expr[:LEFT_JOIN]
    str += expr[:LEFT_OUTER_JOIN].map { |from, cond| " LEFT OUTER JOIN #{from} ON #{cond}" }.join if expr[:LEFT_OUTER_JOIN]
    str += expr[:JOIN_LATERAL].map {|i| " JOIN LATERAL (#{i[:select_statement]}) #{i[:join_name]} ON #{i[:success_condition]}"}.join if expr[:JOIN_LATERAL]

    str += expr[:LEFT_JOIN_LATERAL].map {|i| " LEFT JOIN LATERAL (#{i[:select_statement]}) #{i[:join_name]} ON #{i[:success_condition]}"}.join if expr[:LEFT_JOIN_LATERAL]
    str += ' WHERE ' + expr[:WHERE].map { |w| "(#{w})" }.join(' AND ') if expr[:WHERE]
    str += ' GROUP BY ' + expr[:GROUP_BY].join(', ') if expr[:GROUP_BY]
    str += ' HAVING ' + expr[:HAVING].map { |h| "(#{h})" }.join(' AND ') if expr[:HAVING]
    str += ' ORDER BY ' + expr[:ORDER_BY].map { |col, order| col + (order ? ' ' + order : '') }.join(', ') if expr[:ORDER_BY]
    str += ' LIMIT ' + expr[:LIMIT] if expr[:LIMIT]
    str += ' OFFSET ' + expr[:OFFSET] if expr[:OFFSET]
    str = "(#{str}) AS #{expr[:AS]}" if expr[:AS]
    str = "EXPLAIN #{str}" if expr[:EXPLAIN]
    str
  end

  # Parse a Qx expression tree into a single query string that can be executed
  # http://www.postgresql.org/docs/9.0/static/sql-commands.html
  def self.parse(expr)
    if expr.is_a?(String)
      return expr # already parsed
    elsif expr.is_a?(Array)
      return expr.join(',')
    elsif expr[:INSERT_INTO]
      str =  "INSERT INTO #{expr[:INSERT_INTO]} (#{expr[:INSERT_COLUMNS].join(', ')})"
      throw ArgumentError.new('VALUES (or SELECT) clause is missing for INSERT INTO') unless expr[:VALUES] || expr[:SELECT]
      throw ArgumentError.new("For safety, you can't use SELECT without insert columns for an INSERT INTO") if !expr[:INSERT_COLUMNS] && expr[:SELECT]
      if expr[:SELECT]
        str += ' ' + parse_select(expr)
      else
        str += " VALUES #{expr[:VALUES].map { |vals| "(#{vals.join(', ')})" }.join(', ')}"
      end
      if expr[:ON_CONFLICT]
        str += ' ON CONFLICT'

        if expr[:CONFLICT_COLUMNS]
          str += " (#{expr[:CONFLICT_COLUMNS].join(', ')})"
        elsif expr[:ON_CONSTRAINT]
          str += " ON CONSTRAINT #{expr[:ON_CONSTRAINT]}"
        end
        str += ' DO NOTHING' if !expr[:CONFLICT_UPSERT]
        if expr[:CONFLICT_UPSERT]
          set_str = expr[:INSERT_COLUMNS].select{|i| i != 'created_at'}.map{|i| "#{i} = EXCLUDED.#{i}" }
          str +=  " DO UPDATE SET #{set_str.join(', ')}"
        end
      end
      str += ' RETURNING ' + expr[:RETURNING].join(', ') if expr[:RETURNING]
    elsif expr[:SELECT]
      str = parse_select(expr)
    elsif expr[:DELETE_FROM]
      str = 'DELETE FROM ' + expr[:DELETE_FROM]
      throw ArgumentError.new('WHERE clause is missing for DELETE FROM') unless expr[:WHERE]
      str += ' WHERE ' + expr[:WHERE].map { |w| "(#{w})" }.join(' AND ')
      str += ' RETURNING ' + expr[:RETURNING].join(', ') if expr[:RETURNING]
    elsif expr[:UPDATE]
      str =  'UPDATE ' + expr[:UPDATE]
      throw ArgumentError.new('SET clause is missing for UPDATE') unless expr[:SET]
      throw ArgumentError.new('WHERE clause is missing for UPDATE') unless expr[:WHERE]
      str += ' SET ' + expr[:SET]
      str += ' FROM ' + expr[:FROM] if expr[:FROM]
      str += ' WHERE ' + expr[:WHERE].map { |w| "(#{w})" }.join(' AND ')
      str += ' ' + expr[:ON_CONFLICT] if expr[:ON_CONFLICT]
      str += ' RETURNING ' + expr[:RETURNING].join(', ') if expr[:RETURNING]
    end
    str
  end

  # An instance method version of the above
  def parse
    Qx.parse(@tree)
  end

  # Qx.select("id").from("supporters").execute
  def execute(options = {})
    expr = Qx.parse(@tree).to_s.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
    Qx.execute_raw(expr, options)
  end
  alias ex execute

  # Can pass in an expression string or another Qx object
  # Qx.execute("SELECT id FROM table_name", {format: 'csv'})
  # Qx.execute(Qx.select("id").from("table_name"))
  def self.execute(expr, data = {}, options = {})
    return expr.execute(data) if expr.is_a?(Qx)
    interpolated = Qx.interpolate_expr(expr, data)
    execute_raw(interpolated, options)
  end

  # options
  #   verbose: print the query
  #   format: 'csv' | 'hash'    give data csv style with Arrays -- good for exports or for saving memory
  def self.execute_raw(expr, options = {})
    puts expr if options[:verbose]
    if options[:copy_csv]
      expr = "COPY (#{expr}) TO '#{options[:copy_csv]}' DELIMITER ',' CSV HEADER"
    end
    result = ActiveRecord::Base.connection.execute(expr)
    result.map_types!(@@type_map) if @@type_map
    if options[:format] == 'csv'
      data = result.map(&:values)
      data.unshift((result.first || {}).keys)
    else
      data = result.map { |h| h }
    end
    result.clear
    data = data.map { |row| apply_nesting(row) } if options[:nesting]
    data
  end

  def self.execute_file(path, data = {}, options = {})
    Qx.execute_raw(Qx.interpolate_expr(File.open(path, 'r').read, data), options)
  end

  # helpers for JSON conversion
  def to_json(name)
    name = name.to_s
    Qx.select("array_to_json(array_agg(row_to_json(#{name})))").from(as(name))
  end

  # -- Top-level clauses

  def self.select(*cols)
    new(SELECT: cols)
  end

  def select(*cols)
    @tree[:SELECT] = cols
    self
  end

  def add_select(*cols)
    @tree[:SELECT].push(cols)
    self
  end

  # @returns [Qx]
  def self.insert_into(table_name, cols = [])
    new(INSERT_INTO: Qx.quote_ident(table_name), INSERT_COLUMNS: cols.map { |c| Qx.quote_ident(c) })
  end

  def insert_into(table_name, cols = [])
    @tree[:INSERT_INTO] = Qx.quote_ident(table_name)
    @tree[:INSERT_COLUMNS] = cols.map { |c| Qx.quote_ident(c) }
    self
  end

  def self.delete_from(table_name)
    new(DELETE_FROM: Qx.quote_ident(table_name))
  end

  def delete_from(table_name)
    @tree[:DELETE_FROM] = Qx.quote_ident(table_name)
    self
  end

  def self.update(table_name)
    new(UPDATE: Qx.quote_ident(table_name))
  end

  def update(table_name)
    @tree[:UPDATE] = Qx.quote_ident(table_name)
    self
  end

  # -- Sub-clauses

  # - SELECT sub-clauses

  def distinct
    @tree[:DISTINCT] = true
    self
  end

  def distinct_on(*cols)
    @tree[:DISTINCT_ON] = cols
    self
  end

  def from(expr)
    @tree[:FROM] = expr.is_a?(Qx) ? expr.parse : expr.to_s
    self
  end

  def as(table_name)
    @tree[:AS] = Qx.quote_ident(table_name)
    self
  end

  # Clauses are pairs of expression and data
  def where(*clauses)
    ws = Qx.get_where_params(clauses)
    @tree[:WHERE] = Qx.parse_wheres(ws)
    self
  end

  def and_where(*clauses)
    ws = Qx.get_where_params(clauses)
    @tree[:WHERE] ||= []
    @tree[:WHERE].concat(Qx.parse_wheres(ws))
    self
  end

  def group_by(*cols)
    @tree[:GROUP_BY] = cols.map(&:to_s)
    self
  end

  def order_by(*cols)
    orders = /(asc)|(desc)( nulls (first)|(last))?/i
    # Sanitize out invalid order keywords
    @tree[:ORDER_BY] = cols.map { |col, order| [col.to_s, order.to_s.downcase.strip.match(order.to_s.downcase) ? order.to_s.upcase : nil] }
    self
  end

  def having(expr, data = {})
    @tree[:HAVING] = [Qx.interpolate_expr(expr, data)]
    self
  end

  def and_having(expr, data = {})
    @tree[:HAVING].push(Qx.interpolate_expr(expr, data))
    self
  end

  def limit(n)
    @tree[:LIMIT] = n.to_i.to_s
    self
  end

  def offset(n)
    @tree[:OFFSET] = n.to_i.to_s
    self
  end

  def join(*joins)
    js = Qx.get_join_param(joins)
    @tree[:JOIN] = Qx.parse_joins(js)
    self
  end

  def add_join(*joins)
    js = Qx.get_join_param(joins)
    @tree[:JOIN] ||= []
    @tree[:JOIN].concat(Qx.parse_joins(js))
    self
  end

  def left_join(*joins)
    js = Qx.get_join_param(joins)
    @tree[:LEFT_JOIN] = Qx.parse_joins(js)
    self
  end

  def add_left_join(*joins)
    js = Qx.get_join_param(joins)
    @tree[:LEFT_JOIN] ||= []
    @tree[:LEFT_JOIN].concat(Qx.parse_joins(js))
    self
  end

  def left_outer_join(*joins)
    js = Qx.get_join_param(joins)
    @tree[:LEFT_OUTER_JOIN] = Qx.parse_joins(js)
    self
  end

  def add_left_outer_join(*joins)
    js = Qx.get_join_param(joins)
    @tree[:LEFT_OUTER_JOIN] ||= []
    @tree[:LEFT_OUTER_JOIN].concat(Qx.parse_joins(js))
    self
  end

  def join_lateral(join_name, select_statement, success_condition=true)
    
    @tree[:JOIN_LATERAL] ||= []
    @tree[:JOIN_LATERAL].concat([{join_name: join_name, select_statement: select_statement, success_condition: success_condition}])
    self
  end


  def left_join_lateral(join_name, select_statement, success_condition=true)
    
    @tree[:LEFT_JOIN_LATERAL] ||= []
    @tree[:LEFT_JOIN_LATERAL].concat([{join_name: join_name, select_statement: select_statement, success_condition: success_condition}])
    self
  end

  # - INSERT INTO / UPDATE

  # Allows three formats:
  #   insert.values([[col1, col2], [val1, val2], [val3, val3]], options)
  #   insert.values([{col1: val1, col2: val2}, {col1: val3, co2: val4}], options)
  #   insert.values({col1: val1, col2: val2}, options)  <- only for single inserts
  def values(vals)
    if vals.is_a?(Array) && vals.first.is_a?(Array)
      cols = vals.first
      data = vals[1..-1]
    elsif vals.is_a?(Array) && vals.first.is_a?(Hash)
      hashes = vals.map { |h| h.sort.to_h } # Make sure hash keys line up with all row data
      cols = hashes.first.keys
      data = hashes.map(&:values)
    elsif vals.is_a?(Hash)
      cols = vals.keys
      data = [vals.values]
    end
    @tree[:VALUES] = data.map { |vals| vals.map { |d| Qx.quote(d) } }
    @tree[:INSERT_COLUMNS] = cols.map { |c| Qx.quote_ident(c) }
    self
  end

  # A convenience function for setting the same values across all inserted rows
  def common_values(h)
    cols = h.keys.map { |col| Qx.quote_ident(col) }
    data = h.values.map { |val| Qx.quote(val) }
    @tree[:VALUES] = @tree[:VALUES].map { |row| row.concat(data) }
    @tree[:INSERT_COLUMNS] = @tree[:INSERT_COLUMNS].concat(cols)
    self
  end

  # add timestamps to an insert or update
  def ts
    now = "'#{Time.now.utc}'"
    if @tree[:VALUES]
      @tree[:INSERT_COLUMNS].concat %w[created_at updated_at]
      @tree[:VALUES] = @tree[:VALUES].map { |arr| arr.concat [now, now] }
    elsif @tree[:SET]
      @tree[:SET] += ", updated_at = #{now}"
    end
    self
  end
  alias timestamps ts

  def returning(*cols)
    @tree[:RETURNING] = cols.map { |c| Qx.quote_ident(c) }
    self
  end

  # Vals can be a raw SQL string or a hash of data
  def set(vals)
    if vals.is_a? Hash
      vals = vals.map { |key, val| "#{Qx.quote_ident(key)} = #{Qx.quote(val)}" }.join(', ')
    end
    @tree[:SET] = vals.to_s
    self
  end

  def on_conflict()
    @tree[:ON_CONFLICT] = true
    self
  end

  def conflict_columns(*columns)
    @tree[:CONFLICT_COLUMNS] = columns
    self
  end

  def on_constraint(constraint)
    @tree[:ON_CONSTRAINT] = constraint
    self
  end

  def upsert(on_index, columns=nil)
    @tree[:CONFLICT_UPSERT] = {index: on_index, cols: columns}
    self
  end

  def explain
    @tree[:EXPLAIN] = true
    self
  end

  # -- Helpers!

  def self.fetch(table_name, data, options = {})
    expr = Qx.select('*').from(table_name)
    if data.is_a?(Hash)
      expr = data.reduce(expr) { |acc, pair| acc.and_where("#{pair.first} IN ($vals)", vals: Array(pair.last)) }
    else
      expr = expr.where('id IN ($ids)', ids: Array(data))
    end
    result = expr.execute(options)
    result
  end

  # Given a Qx expression, add a LIMIT and OFFSET for pagination
  def paginate(current_page, page_length)
    current_page = 1 if current_page.nil? || current_page < 1
    limit(page_length).offset((current_page - 1) * page_length)
  end

  def pp
    str = parse
    # Colorize some tokens
    # TODO indent by paren levels
    str = str
          .gsub(/(FROM|WHERE|VALUES|SET|SELECT|UPDATE|INSERT INTO|DELETE FROM)/) { Regexp.last_match(1).to_s.blue.bold }
          .gsub(/(\(|\))/) { Regexp.last_match(1).to_s.cyan }
          .gsub('$Q$', "'")
    str
  end

  # -- utils

  attr_reader :tree

  # Safely interpolate some data into a SQL expression
  def self.interpolate_expr(expr, data = {})
    expr.to_s.gsub(/\$\w+/) do |match|
      val = data[match.gsub(/[ \$]*/, '').to_sym]
      vals = val.is_a?(Array) ? val : [val]
      vals.map { |x| Qx.quote(x) }.join(', ')
    end
  end

  # Quote a string for use in sql to prevent injection or weird errors
  # Always use this for all values!
  # Just uses double-dollar quoting universally. Should be generally safe and easy.
  # Will return an unquoted value it it's a Fixnum
  def self.quote(val)
    if val.is_a?(Qx)
      val.parse
    elsif val.is_a?(Integer)
      val.to_s
    elsif val.is_a?(Time)
      "'" + val.to_s + "'" # single-quoted times for a little better readability
    elsif val.nil?
      'NULL'
    elsif !!val == val # is a boolean
      val ? "'t'" : "'f'"
    else
      '$Q$' + val.to_s + '$Q$'
    end
  end

  # Double-quote sql identifiers (or parse Qx trees for subqueries)
  def self.quote_ident(expr)
    if expr.is_a?(Qx)
      Qx.parse(expr.tree)
    else
      expr.to_s.split('.').map { |s| s == '*' ? s : "\"#{s}\"" }.join('.')
    end
  end

  # Remove a clause from the sql tree
  def remove_clause(name)
    name = name.to_s.upcase.tr(' ', '_').to_sym
    @tree.delete(name)
    self
  end

  private # Internal utils

  # Turn join params into something that .parse can use
  def self.parse_joins(js)
    js.map { |table, cond, data| [table.is_a?(Qx) ? table.parse : table, Qx.interpolate_expr(cond, data)] }
  end

  # Given an array, determine if it has the form
  # [[join_table, join_on, data], ...]
  # or
  # [join_table, join_on, data]
  # Always return the former format
  def self.get_join_param(js)
    js.first.is_a?(Array) ? js : [[js.first, js[1], js[2]]]
  end

  # given either a single hash or a string expr + data, parse it into a single string expression
  def self.parse_wheres(clauses)
    clauses.map do |expr, data|
      if expr.is_a?(Hash)
        expr.map { |key, val| "#{Qx.quote_ident(key)} IN (#{Qx.quote(val)})" }.join(' AND ')
      else
        Qx.interpolate_expr(expr, data)
      end
    end
  end

  # Similar to get_joins_params, except each where clause is a pair, not a triplet
  def self.get_where_params(ws)
    ws.first.is_a?(Array) ? ws : [[ws.first, ws[1]]]
  end

  # given either a single, hash, array of hashes, or csv style, turn it all into csv style
  # util for INSERT INTO x (y) VALUES z
  def self.parse_val_params(vals)
    if vals.is_a?(Array) && vals.first.is_a?(Array)
      cols = vals.first
      data = vals[1..-1]
    elsif vals.is_a?(Array) && vals.first.is_a?(Hash)
      hashes = vals.map { |h| h.sort.to_h }
      cols = hashes.first.keys
      data = hashes.map(&:values)
    elsif vals.is_a?(Hash)
      cols = vals.keys
      data = [vals.values]
    end
    [cols, data]
  end
end
