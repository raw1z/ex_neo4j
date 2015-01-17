defmodule HelpersText do
  use ExUnit.Case, async: true
  alias ExNeo4j.Helpers

  test "translates a cypher query without arguments to a statement" do
    query = "match (n) return n"
    statements = Helpers.format_statements([{query, %{}}])
    assert statements == ~s({"statements":[{"statement":"#{query}"}]})
  end

  test "translates a cypher query with arguments to a statement" do
    query = "match (n {props}) return n"
    statements = Helpers.format_statements([{query, %{props: %{name: "foo"}}}])
    assert statements == ~s({"statements":[{"statement":"#{query}","parameters":{"props":{"name":"foo"}}}]})
  end

  test "translates several cypher queries to a statement" do
    query1 = "match (n) return n"
    query2 = "match (n {props}) return n"
    statements = Helpers.format_statements([{query1, %{}}, {query2, %{props: %{name: "foo"}}}])
    assert statements == ~s({"statements":[{"statement":"#{query1}"},{"statement":"#{query2}","parameters":{"props":{"name":"foo"}}}]})
  end
end
