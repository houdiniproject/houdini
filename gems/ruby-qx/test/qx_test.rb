require './lib/qx.rb'
require 'pg'
require 'minitest/autorun'
require 'pry'

ActiveRecord::Base.establish_connection('postgres://admin:password@localhost/qx_test')
tm = PG::BasicTypeMapForResults.new(ActiveRecord::Base.connection.raw_connection)
Qx.config(type_map: tm)
# Execute test schema
Qx.execute_file('./test/test_schema.sql')

class QxTest < Minitest::Test

  def setup
  end

  # Let's just test that the schema was executed
  def test_execute_file
    email = 'uzzzr@example.com'
    result = Qx.execute_file('./test/test_insert_user.sql', email: email, id: 1).last
    Qx.delete_from(:users).where(id: 1).ex
    assert_equal email, result['email']
  end

  def test_select_from
    parsed = Qx.select(:id, "name").from(:table_name).parse
    assert_equal parsed, %Q(SELECT id, name FROM table_name)
  end
  def test_select_distinct_on
    parsed = Qx.select(:id, "name").distinct_on(:distinct_col1, :distinct_col2).from(:table_name).parse
    assert_equal parsed, %Q(SELECT DISTINCT ON (distinct_col1, distinct_col2) id, name FROM table_name)
  end
  def test_select_distinct
    parsed = Qx.select(:id, "name").distinct.from(:table_name).parse
    assert_equal parsed, %Q(SELECT DISTINCT id, name FROM table_name)
  end

  def test_select_as
    parsed = Qx.select(:id, "name").from(:table_name).as(:alias).parse
    assert_equal parsed, %Q((SELECT id, name FROM table_name) AS "alias")
  end
  
  def test_select_where
    parsed = Qx.select(:id, "name").from(:table_name).where("x = $y OR a = $b", y: 1, b: 2).parse
    assert_equal parsed, %Q(SELECT id, name FROM table_name WHERE (x = 1 OR a = 2))
  end
  def test_select_where_hash_array
    parsed = Qx.select(:id, "name").from(:table_name).where([x: 1], ["y = $n", {n: 2}]).parse
    assert_equal parsed, %Q(SELECT id, name FROM table_name WHERE ("x" IN (1)) AND (y = 2))
  end
  def test_select_and_where
    parsed = Qx.select(:id, "name").from(:table_name).where("x = $y", y: 1).and_where("a = $b", b: 2).parse
    assert_equal parsed, %Q(SELECT id, name FROM table_name WHERE (x = 1) AND (a = 2))
  end
  def test_select_and_where_hash
    parsed = Qx.select(:id, "name").from(:table_name).where("x = $y", y: 1).and_where(a: 2).parse
    assert_equal parsed, %Q(SELECT id, name FROM table_name WHERE (x = 1) AND ("a" IN (2)))
  end
  
  def test_select_and_group_by
    parsed = Qx.select(:id, "name").from(:table_name).group_by("col1", "col2").parse
    assert_equal parsed, %Q(SELECT id, name FROM table_name GROUP BY col1, col2)
  end
  
  def test_select_and_order_by
    parsed = Qx.select(:id, "name").from(:table_name).order_by("col1", ["col2", "DESC NULLS LAST"]).parse
    assert_equal parsed, %Q(SELECT id, name FROM table_name ORDER BY col1 , col2 DESC NULLS LAST)
  end

  def test_select_having
    parsed = Qx.select(:id, "name").from(:table_name).having("COUNT(col1) > $n", n: 1).parse
    assert_equal parsed, %Q(SELECT id, name FROM table_name HAVING (COUNT(col1) > 1))
  end
  def test_select_and_having
    parsed = Qx.select(:id, "name").from(:table_name).having("COUNT(col1) > $n", n: 1).and_having("SUM(col2) > $m", m: 2).parse
    assert_equal parsed, %Q(SELECT id, name FROM table_name HAVING (COUNT(col1) > 1) AND (SUM(col2) > 2))
  end

  def test_select_limit
    parsed = Qx.select(:id, "name").from(:table_name).limit(10).parse
    assert_equal parsed, %Q(SELECT id, name FROM table_name LIMIT 10)
  end
  def test_select_offset
    parsed = Qx.select(:id, "name").from(:table_name).offset(10).parse
    assert_equal parsed, %Q(SELECT id, name FROM table_name OFFSET 10)
  end

  def test_select_join
    parsed = Qx.select(:id, "name").from(:table_name).join(['assoc1', 'assoc1.table_name_id=table_name.id']).parse
    assert_equal parsed, %Q(SELECT id, name FROM table_name JOIN assoc1 ON assoc1.table_name_id=table_name.id)
  end
  def test_select_add_join
    parsed = Qx.select(:id, "name").from(:table_name).join('assoc1', 'assoc1.table_name_id=table_name.id')
      .add_join(['assoc2', 'assoc2.table_name_id=table_name.id']).parse
    assert_equal parsed, %Q(SELECT id, name FROM table_name JOIN assoc1 ON assoc1.table_name_id=table_name.id JOIN assoc2 ON assoc2.table_name_id=table_name.id)
  end
  def test_select_left_join
    parsed = Qx.select(:id, "name").from(:table_name).left_join(['assoc1', 'assoc1.table_name_id=table_name.id']).parse
    assert_equal parsed, %Q(SELECT id, name FROM table_name LEFT JOIN assoc1 ON assoc1.table_name_id=table_name.id)
  end
  def test_select_add_left_join
    parsed = Qx.select(:id, "name").from(:table_name).left_join('assoc1', 'assoc1.table_name_id=table_name.id')
      .add_left_join(['assoc2', 'assoc2.table_name_id=table_name.id']).parse
    assert_equal parsed, %Q(SELECT id, name FROM table_name LEFT JOIN assoc1 ON assoc1.table_name_id=table_name.id LEFT JOIN assoc2 ON assoc2.table_name_id=table_name.id)
  end

  def test_select_where_subquery
    parsed = Qx.select(:id, "name").from(:table_name).where("id IN ($ids)", ids: Qx.select("id").from("assoc")).parse
    assert_equal parsed, %Q(SELECT id, name FROM table_name WHERE (id IN (SELECT id FROM assoc)))
  end

  def test_select_join_subquery
    parsed = Qx.select(:id).from(:table).join([Qx.select(:id).from(:assoc).as(:assoc), "assoc.table_id=table.id"]).parse
    assert_equal parsed, %Q(SELECT id FROM table JOIN (SELECT id FROM assoc) AS "assoc" ON assoc.table_id=table.id)
  end

  def test_select_from_subquery
    parsed = Qx.select(:id).from(Qx.select(:id).from(:table).as(:table)).parse
    assert_equal parsed, %Q(SELECT id FROM (SELECT id FROM table) AS "table")
  end

  def test_select_integration
    parsed = Qx.select(:id)
      .from(:table)
      .join([Qx.select(:id).from(:assoc).as(:assoc), 'assoc.table_id=table.id'])
      .left_join(['lefty', 'lefty.table_id=table.id'])
      .where('x = $n', n: 1)
      .and_where('y = $n', n: 1)
      .group_by(:x)
      .order_by(:y)
      .having('COUNT(x) > $n', n: 1)
      .and_having('COUNT(y) > $n', n: 1)
      .limit(10)
      .offset(10)
      .parse
    assert_equal parsed, %Q(SELECT id FROM table JOIN (SELECT id FROM assoc) AS "assoc" ON assoc.table_id=table.id LEFT JOIN lefty ON lefty.table_id=table.id WHERE (x = 1) AND (y = 1) GROUP BY x HAVING (COUNT(x) > 1) AND (COUNT(y) > 1) ORDER BY y  LIMIT 10 OFFSET 10)
  end

  def test_insert_into_values_hash
    parsed = Qx.insert_into(:table_name).values(x: 1).parse
    assert_equal parsed, %Q(INSERT INTO "table_name" ("x") VALUES (1))
  end
  def test_insert_into_values_hash_array
    parsed = Qx.insert_into(:table_name).values([{x: 1}, {x: 2}]).parse
    assert_equal parsed, %Q(INSERT INTO "table_name" ("x") VALUES (1), (2))
  end
  def test_insert_into_values_csv_style
    parsed = Qx.insert_into(:table_name).values([['x'], [1], [2]]).parse
    assert_equal parsed, %Q(INSERT INTO "table_name" ("x") VALUES (1), (2))
  end
  def test_insert_into_values_common_values
    parsed = Qx.insert_into(:table_name).values([{x: 'bye'}, {x: 'hi'}]).common_values(z: 1).parse
    assert_equal parsed, %Q(INSERT INTO "table_name" ("x", "z") VALUES ($Q$bye$Q$, 1), ($Q$hi$Q$, 1))
  end
  def test_insert_into_values_timestamps
    parsed = Qx.insert_into(:table_name).values(x: 1).ts.parse
    assert_equal parsed, %Q(INSERT INTO "table_name" ("x", created_at, updated_at) VALUES (1, '#{Time.now.utc}', '#{Time.now.utc}'))
  end
  def test_insert_into_values_returning
    parsed = Qx.insert_into(:table_name).values(x: 1).returning('*').parse
    assert_equal parsed, %Q(INSERT INTO "table_name" ("x") VALUES (1) RETURNING *)
  end
  def test_insert_into_select
    parsed = Qx.insert_into(:table_name, ['hi']).select('hi').from(:table2).where("x=y").parse
    assert_equal parsed, %Q(INSERT INTO "table_name" ("hi") SELECT hi FROM table2 WHERE (x=y))
  end

  def test_update_set
    parsed = Qx.update(:table_name).set(x: 1).where("y = 2").parse
    assert_equal parsed, %Q(UPDATE "table_name" SET "x" = 1 WHERE (y = 2))
  end
  def test_update_timestamps
    now = Time.now.utc
    parsed = Qx.update(:table_name).set(x: 1).where("y = 2").timestamps.parse
    assert_equal parsed, %Q(UPDATE "table_name" SET "x" = 1, updated_at = '#{now}' WHERE (y = 2))
  end

  def test_update_on_conflict
    Qx.update(:table_name).set(x: 1).where("y = 2").on_conflict(:nothing).parse
    assert_equal parsed, %Q(UPDATE "table_name" SET "x" = 1 WHERE (y = 2) ON CONFLICT DO NOTHING)
  end

  def test_insert_timestamps
    now = Time.now.utc
    parsed = Qx.insert_into(:table_name).values({x: 1}).ts.parse
    assert_equal parsed, %Q(INSERT INTO "table_name" ("x", created_at, updated_at) VALUES (1, '#{now}', '#{now}'))
  end

  def test_delete_from
    parsed = Qx.delete_from(:table_name).where(x: 1).parse
    assert_equal parsed, %Q(DELETE FROM "table_name" WHERE ("x" IN (1)))
  end

  def test_pagination
    parsed = Qx.select(:x).from(:y).paginate(4, 30).parse
    assert_equal parsed, %Q(SELECT x FROM y LIMIT 30 OFFSET 90)
  end

  def test_execute_string
    result = Qx.execute("SELECT * FROM (VALUES ($x)) AS t", x: 'x')
    assert_equal result, [{'column1' => 'x'}]
  end
  def test_execute_format_csv
    result = Qx.execute("SELECT * FROM (VALUES ($x)) AS t", {x: 'x'}, {format: 'csv'})
    assert_equal result, [['column1'], ['x']]
  end
  def test_execute_on_instances
    result = Qx.insert_into(:users).values(id: 1, email: 'uzr@example.com').execute
    result = Qx.execute(Qx.select("*").from(:users).limit(1))
    assert_equal result, [{'id' => 1, 'email' => 'uzr@example.com'}]
    Qx.delete_from(:users).where(id: 1).execute
  end

  def test_explain
    parsed = Qx.select("*").from("table_name").explain.parse
    assert_equal parsed, %Q(EXPLAIN SELECT * FROM table_name)
  end

  # Manually test this one for now
  def test_pp_select
    pp = Qx.select("id, name").from("table_name").where(status: 'active').and_where(id: Qx.select("id").from("roles").where(name: "admin")).pp
    pp2 = Qx.insert_into(:table_name).values([x: 1, y: 2]).pp
    pp3 = Qx.update(:table_name).set(x: 1, y: 2).where(z: 1, a: 22).pp
    pp_delete = Qx.delete_from(:table_name).where(id: 123).pp
    puts ""
    puts "--- pretty print"
    puts pp
    puts pp2
    puts pp3
    puts pp_delete
    puts "---"
  end

  def test_to_json
    parsed = Qx.select(:id).from(:users).to_json(:t).parse
    assert_equal parsed, %Q(SELECT array_to_json(array_agg(row_to_json(t))) FROM (SELECT id FROM users) AS "t")
  end

  def test_to_json_nested
    definitions = Qx.select(:part_of_speech, :body)
      .from(:definitions)
      .where("word_id=words.id")
      .order_by("position ASC")
      .to_json(:ds)
      .as("definitions")
    parsed = Qx.select(:text, :pronunciation, definitions)
      .from(:words)
      .where("text='autumn'")
      .to_json(:ws)
      .parse
    assert_equal parsed, "SELECT array_to_json(array_agg(row_to_json(ws))) FROM (SELECT text, pronunciation, (SELECT array_to_json(array_agg(row_to_json(ds))) FROM (SELECT part_of_speech, body FROM definitions WHERE (word_id=words.id) ORDER BY position ASC ) AS \"ds\") AS \"definitions\" FROM words WHERE (text='autumn')) AS \"ws\""
  end

  def test_copy_csv_execution
    data = {'id' => '1', 'email' => 'uzr@example.com'}
    filename = '/tmp/qx-test.csv'
    Qx.insert_into(:users).values(data).ex
    copy = Qx.select("*").from("users").execute(copy_csv: filename)
    contents = File.open(filename, 'r').read
    csv_data = contents.split("\n").map{|l| l.split(",")}
    headers = csv_data.first
    row = csv_data.last
    assert_equal data.keys, headers
    assert_equal data.values, row
  end

  def test_remove_clause
    expr = Qx.select("*").from("table").limit(1)
    expr = expr.remove_clause('limit')
    assert_equal "SELECT * FROM table", expr.parse
  end



end
