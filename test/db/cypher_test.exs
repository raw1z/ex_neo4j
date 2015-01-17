defmodule CypherTest do
  use ExUnit.Case
  alias ExNeo4j.Db
  alias ExNeo4j.Helpers

  setup do
    Mock.fake

    on_exit fn ->
      Mock.unload
    end
  end

  test "execute a query without arguments" do
    query = "match (n) return n"
    statements = Helpers.format_statements([{query, %{}}])

    Mock.http_request :post, [ "/db/data/transaction/commit", statements ], """
    {
      "errors": [],
      "results": [
        {
          "columns": ["n"],
          "data": [
            {"row": [{"name":"John Doe","email":"john@doe.dummy","type":"customer"}]}
          ]
        }
      ]
    }
    """

    Db.start
    {:ok, results} = Db.cypher(query)
    assert Enum.count(results) == 1

    item = results |> List.first |> Map.get("n")
    assert item["name"] == "John Doe"
    assert item["email"] == "john@doe.dummy"
    assert item["type"] == "customer"
  end

  test "execute a query with arguments" do
    query = "match (n {props}) return n"
    params = %{props: %{name: "John Doe"}}
    statements = Helpers.format_statements([{query, params}])

    Mock.http_request :post, [ "/db/data/transaction/commit", statements ], """
    {
      "errors": [],
      "results": [
        {
          "columns": ["n"],
          "data": [
            {"row": [{"name":"John Doe","email":"john@doe.dummy","type":"customer"}]}
          ]
        }
      ]
    }
    """

    Db.start
    {:ok, results} = Db.cypher(query, params)
    assert Enum.count(results) == 1

    item = results |> List.first |> Map.get("n")
    assert item["name"] == "John Doe"
    assert item["email"] == "john@doe.dummy"
    assert item["type"] == "customer"
  end

  test "executes multiple queries" do
    query1 = "match (n) return n"
    query1_params = %{}
    query2 = "match (n {props}) return n"
    query2_params = %{props: %{name: "John Doe"}}
    statements = Helpers.format_statements([{query1, query1_params}, {query2, query2_params}])

    Mock.http_request :post, [ "/db/data/transaction/commit", statements ], """
    {
      "errors": [],
      "results": [
        {
          "columns": ["n"],
          "data": [
            {"row": [{"name":"John Doe","email":"john@doe.dummy","type":"customer"}]},
            {"row": [{"name":"Jane Doe","email":"jane@doe.dummy","type":"customer"}]}
          ]
        },
        {
          "columns": ["n"],
          "data": [
            {"row": [{"name":"John Doe","email":"john@doe.dummy","type":"customer"}]}
          ]
        }
      ]
    }
    """

    Db.start
    {:ok, results} = Db.cypher([{query1, query1_params}, {query2, query2_params}])
    assert Enum.count(results) == 2

    item = results |> Enum.at(0) |> List.first |> Map.get("n")
    assert item["name"] == "John Doe"
    assert item["email"] == "john@doe.dummy"
    assert item["type"] == "customer"

    item = results |> Enum.at(0) |> List.last |> Map.get("n")
    assert item["name"] == "Jane Doe"
    assert item["email"] == "jane@doe.dummy"
    assert item["type"] == "customer"

    item = results |> Enum.at(1) |> List.first |> Map.get("n")
    assert item["name"] == "John Doe"
    assert item["email"] == "john@doe.dummy"
    assert item["type"] == "customer"
  end
end
