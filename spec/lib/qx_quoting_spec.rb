# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

# Every value Qx and Qexpr interpolate has to reach the database as one
# literal, whatever characters it contains.
describe "Qx and Qexpr value quoting" do
  tricky_values = [
    "plain",
    "it's",
    "''",
    "back\\slash",
    "$Q$",
    "a$Q$b",
    "$Q$already quoted$Q$",
    "$$",
    "$tag$x$tag$",
    "line\nbreak",
    "10/01/ 26"
  ]

  def select_literal(sql)
    ActiveRecord::Base.connection.select_value("SELECT #{sql}")
  end

  describe "Qx.quote" do
    tricky_values.each do |value|
      it "round-trips #{value.inspect} unchanged" do
        expect(select_literal(Qx.quote(value))).to eq value
      end
    end

    it "leaves integers, nil and booleans as before" do
      expect(Qx.quote(5)).to eq "5"
      expect(Qx.quote(nil)).to eq "NULL"
      expect(Qx.quote(true)).to eq "'t'"
      expect(Qx.quote(false)).to eq "'f'"
    end
  end

  describe "Qx.interpolate_expr" do
    tricky_values.each do |value|
      it "round-trips #{value.inspect} through an expression" do
        result = Qx.execute("SELECT $val AS val, $other AS other", val: value, other: "after").first
        expect(result).to eq("val" => value, "other" => "after")
      end
    end

    it "quotes each element of an array" do
      sql = Qx.interpolate_expr("SELECT unnest(ARRAY[$vals])", vals: ["it's", "$Q$"])
      expect(ActiveRecord::Base.connection.select_values(sql)).to eq ["it's", "$Q$"]
    end
  end

  describe "Qexpr.quote" do
    tricky_values.each do |value|
      it "round-trips #{value.inspect} unchanged" do
        expect(select_literal(Qexpr.quote(value))).to eq value
      end
    end

    it "quotes strings that look already quoted instead of passing them through" do
      expect(Qexpr.quote("$Q$x$Q$")).to eq "'$Q$x$Q$'"
    end

    it "leaves integers, nil and booleans as before" do
      expect(Qexpr.quote(5)).to eq 5
      expect(Qexpr.quote(nil)).to eq "NULL"
      expect(Qexpr.quote(true)).to eq "'t'"
      expect(Qexpr.quote(false)).to eq "'f'"
    end

    it "quotes times so they still compare as timestamps" do
      time = Time.utc(2026, 10, 1, 12, 30)
      expect(select_literal("#{Qexpr.quote(time)}::timestamptz")).to eq time
    end
  end

  describe "Qexpr.interpolate_expr" do
    tricky_values.each do |value|
      it "round-trips #{value.inspect} through an expression" do
        sql = Qexpr.interpolate_expr("SELECT $val AS val, $other AS other", val: value, other: "after")
        expect(ActiveRecord::Base.connection.select_one(sql)).to eq("val" => value, "other" => "after")
      end

      it "keeps #{value.inspect} inside its where condition" do
        query = ->(other) { Qexpr.new.select("1 AS one").from("(SELECT 1) AS t").where("$a = $b", a: value, b: other) }
        expect(Psql.execute(query.call(value)).count).to eq 1
        expect(Psql.execute(query.call("something else")).count).to eq 0
      end
    end
  end

  describe "identifier quoting" do
    tricky_names = ["plain", "Employer's name", 'say "hi"', '"', 'x" FROM pg_class --', "$Q$"]

    tricky_names.each do |name|
      it "Qx.quote_ident keeps #{name.inspect} as one column name" do
        expect(ActiveRecord::Base.connection.select_one("SELECT 1 AS #{Qx.quote_ident(name)}").keys).to eq [name]
      end

      it "Qexpr.quote_ident keeps #{name.inspect} as one column name" do
        expect(ActiveRecord::Base.connection.select_one("SELECT 1 AS #{Qexpr.quote_ident(name)}").keys).to eq [name]
      end
    end

    it "still splits table.column" do
      expect(Qx.quote_ident("supporters.name")).to eq '"supporters"."name"'
      expect(Qexpr.quote_ident("supporters.name")).to eq '"supporters"."name"'
      expect(Qx.quote_ident("supporters.*")).to eq '"supporters".*'
    end
  end
end
