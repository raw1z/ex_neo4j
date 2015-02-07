defmodule CypherTest do
  use ExUnit.Case
  import Mock
  alias ExNeo4j.Db

  test "execute a query without arguments" do
    enable_mock do
      query = "match (n) return n"

      expected_response = """
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

      http_client_returns expected_response,
        for_query: query,
        with_params: %{}

      {:ok, results} = Db.cypher(query)
      assert Enum.count(results) == 1

      item = results |> List.first |> Map.get("n")
      assert item["name"] == "John Doe"
      assert item["email"] == "john@doe.dummy"
      assert item["type"] == "customer"
    end
  end

  test "execute a query with arguments" do
    enable_mock do
      query = "match (n {props}) return n"
      params = %{props: %{name: "John Doe"}}

      expected_response = """
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

      http_client_returns expected_response,
        for_query: query,
        with_params: params

      {:ok, results} = Db.cypher(query, params)
      assert Enum.count(results) == 1

      item = results |> List.first |> Map.get("n")
      assert item["name"] == "John Doe"
      assert item["email"] == "john@doe.dummy"
      assert item["type"] == "customer"
    end
  end

  test "executes multiple queries" do
    query1 = "match (n) return n"
    query1_params = %{}
    query2 = "match (n {props}) return n"
    query2_params = %{props: %{name: "John Doe"}}

    expected_response = """
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

    http_client_returns expected_response,
      for_queries: [query1, query2],
      with_params: [query1_params, query2_params]

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
