# This library is deprecated. You can use [Arel](https://github.com/rails/arel) instead

# Qx

A ruby SQL expression builder (and executor)  focused on Postgresql. It allows you to directly and safely write efficient SQL expressions in Ruby, using data from Ruby-land. These expressions can be passed around, reused, and modified. This lib is for those of us who want to use SQL directly within ruby, and do not want an ORM.

This library uses ActiveRecord for executing SQL, taking advantage of its connection pooling features. If you'd like to see support for Sequel, etc, please make a PR.

This implements a subset of the SQL language that we find most useful so far. Add new SQL clauses with a PR if you'd like to see more in here.

_*Example*_

```rb
# A fairly complex query with subqueries inside some joins:
# Create a select query on the payments table
payments_subquery = Qx.select( "supporter_id", "SUM(gross_amount)", "MAX(date) AS max_date", "MIN(date) AS min_date", "COUNT(*) AS count")
  .from(:payments)
  .group_by(:supporter_id)
  .as(:payments)

# Another subquery
tags_subquery = Qx.select("tag_joins.supporter_id", "ARRAY_AGG(tag_masters.id) AS ids", "ARRAY_AGG(tag_masters.name::text) AS names")
  .from(:tag_joins)
  .join(:tag_masters, "tag_masters.id=tag_joins.tag_master_id")
  .group_by("tag_joins.supporter_id")
  .as(:tags)

# Combine the above subqueries into a select on the supporters table
expr = Qx.select('supporters.id').from(:supporters)
  .left_join(tags_subquery, "tags.supporter_id=supporters.id")
  .add_left_join(payments_subquery, "payments.supporter_id=supporters.id")
  .where("supporters.nonprofit_id=$id", id: np_id.to_i)
  .and_where("coalesce(supporters.deleted, FALSE) = FALSE")
  .order_by('payments.max_date DESC NULLS LAST')
  .execute(format: 'csv')
  
# Easy bulk insert
Qx.insert_into(:table_name).values([{x: 1}, {x: 2}, {x: 3}]).execute
# Qx also supports insert from selects, like `INSERT INTO x (y) SELECT y FROM x`
Qx.insert_into(:table_name, ['x']).select("x").from("table2").execute
```

# Qx.config(options)

`Qx.config` takes a hash of options. For now, there is only one option: `:type_map`, which allows you to specify a PG typemap

```
Qx.config(type_map: PG::BasicTypeMapForResults.new(ActiveRecord::Base.connection.raw_connection))
```

`.config` is best called in an initializer when your app is starting up. Be sure to initialize ActiveRecord before using Qx. In Rails, you don't need to do anything extra for that.

# API

Please refer to this test file to see all the SQL constructor methods: [/test/qx_test.rb](/test/qx_test.rb)

For each test, see the `assert_equal` line to find the resulting SQL expression. Above that, in the `parsed = ...` line, you can see how the expression was created using Qx.

## `expression.execute`

When you have an expression, call `.execute` to actually execute it.

```rb
Qx.select("id", "name").from(:users).where(email: "user@example.com").execute
```

`.ex` is a shortcut alias

## `Qx.execute_file(path, interpolation_data, options)`

This function will open a sql file and execute its contents. You can interpolate data into the file with `$variable_name`.

Given a sql file like:

```sql
SELECT * FROM users WHERE account_id=$account_id LIMIT 1
```

You can execute the file with:

```rb
Qx.execute_file('./get_user.sql', account_id: 123)
# -> [{email: 'uzr@example.com', ...}]
```

## `.parse`

Instead of executing the expression, you can parse the expression into a string:

```rb
Qx.select("id", "name").from(:users).where(email: "user@example.com").parse
# -> "SELECT id, name FROM users WHERE email = 'user@example.com'"
```

Note you can also use `.pp` to pretty-print the expression for debugging (for now it just colorizes, but in the near future it will indent the expression for you)

## shortcut / helper functions

Some convenience functions are provided that compose SQL expressions for you.

### Qx.fetch(table_name, ids_or_data)

This is a quick way to fetch some full rows of data by id or another column. You can either pass in an array of ids, a single id, or a hash that matches on columns.

```rb
Qx.fetch(:table_name, [12, 34, 56])
# SELECT * FROM table_name WHERE ids IN (12, 34, 56)

donation = Qx.fetch(:donations, 23)
# SELECT * FROM donations WHERE ID IN (23)
donor = Qx.fetch(:donors, donation['supporter_id'])
# SELECT * FROM donors WHERE ID IN (33)

# Select by a different column besides "id" -- in this case, we use "status"
donation = Qx.fetch(:donations, {status: 'active'})
# SELECT * FROM donations WHERE status IN ('active')
```

### expr.common_values(hash)

If you're bulk inserting but want some common values in all your rows, you
don't have to have that common data in every single row. Instead, you can use
`.common_values`:

```rb
expr = Qx.insert_into(:table_name)
  .values([{x: 1}, {x: 2}])
  .common_values({y: 'common'})
# INSERT INTO "table_name" ("x", "y")
# VALUES (1, 'common'), (2, 'common')
```

### expr.timestamps

Inside an `INSERT INTO` expression, if you add the `.timestamps` method, it will add both `created_at` and `updated_at` columns, set to the current utc time.

```
Qx.insert_into(:table_name).values(x: 1).timestamps.execute
# INSERT INTO table_name (x, created_at, updated_at) VALUES (1, '2020-01-01 00:00:00 UTC', '2020-01-01 00:00:00 UTC')
# (pretending that the above dates is Time.now)
```

Inside an `UPDATE` expression, `.timestamps` will set the `updated_at` column to the current time for you:

```
Qx.update(:table_name).set(x: 1).timestamps.where(id: 1).execute
# UPDATE table_name SET x=1, updated_at='2020-01-01 00:00:00 UTC' WHERE id=1
```

`.ts` is a shortcut alias for this method

## expr.pp (pretty-printing)

This gives a nicely formatted and colorized output of your expression for debugging.

```rb
Qx.select(:id)
  .from(:table)
  .where("id IN ($ids)", ids: [1,2,3,4]) 
  .pp
```

For now it just adds some syntax highlighting; in the near future it will also add indentation.

## expr.paginate(current_page, page_length)

This is a convenience method for more easily paginating a SELECT query using the combination of OFFSET and LIMIT

Simply pass in the page length and the current page to get the paginated results.

```rb
Qx.select(:id).from(:table).paginate(2, 30)
# SELECT id FROM table OFFSET 30 LIMIT 30
```

## JSON helpers

A helper method, called `.to_json(alias)` allows you to wrap your results in a json blob. Under the hood it composes the postgres functions `array_to_json(array_agg(row_to_json(t)))` to conveniently convert a collection of sql data into a single json blob.

Notice in this example that there is one result with one key called "data", mapped to a single JSON string:

```
Qx.select(:id, :email).from(:users).to_json(:data).execute
# SELECT row_to_json(data) AS data FROM (SELECT id, email FROM users) data
# returns [
#   { "data" => "[{\"id\": 1, \"email\": \"bob@example.com\"}, {\"id\": 1, \"email\": \"bob@example.com\"}]" }
# ]
```

In doing highly nested json, you can call `.to_json(alias)` within different subqueries. This example borrows from a JSON API (jsonapi.org) example:

```rb
definitions = Qx.select(:part_of_speech, :body)
  .from("definitions")
  .where("word_id=words.id")
  .order_by("position ASC")
  .to_json("ds")

expr = Qx.select(:text, :pronunciation, definitions.as("definitions"))
  .from("words")
  .where("text='autumn'")
  .to_json("data")
```

The above nested expression parses into the following sql:

```sql
SELECT array_to_json(array_agg(row_to_json(data))) AS data
FROM (
  SELECT 
    text
  , pronunciation
  , (
      SELECT array_to_json(array_agg(row_to_json(d)))
      FROM (
        SELECT part_of_speech, body
        FROM definitions
        WHERE word_id=words.id
        ORDER BY position asc
      ) d
    ) AS definitions
  FROM words
  WHERE text = 'autumn'
) data
```

And, when executed, will give the following json string:

```json
{
  "text": "autumn",
  "pronunciation": "autumn",
  "definitions": [
    {
        "part_of_speech": "noun",
        "body": "skilder wearifully uninfolded..."
    },
    {
        "part_of_speech": "verb",
        "body": "intrafissural fernbird kittly..."
    },
    {
        "part_of_speech": "adverb",
        "body": "infrugal lansquenet impolarizable..."
    }
  ]
}
```

## Performance Optimization Tools

Since this lib is built with Postgresql, it takes advantage of its performance optimization tools such as EXPLAIN, ANALYZE, and statistics queries.

### expr.explain

For performance optimization, you can use an `EXPLAIN` command on a Qx select expression object (http://www.postgresql.org/docs/9.5/static/using-explain.html).

```rb
Qx.select(:id)
  .from(:table)
  .where("id IN ($ids)", ids: [1,2,3,4]) 
  .explain
  .execute
```


## Development and testing

#### Testing

Set up Postgres on your machine and create a database called `qx_test`. Grant all privileges to a user called `admin` with password `password`

Run tests with `ruby test/qx_test.rb`
