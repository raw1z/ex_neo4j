defmodule Mock do
  use ExActor.GenServer, export: :mock
  alias ExNeo4j.HttpClient

  defstart start_link do
    :meck.new(HttpClient)
    initial_state(nil)
  end

  defcall http_request(method, params, expected_response), state: state do
    mock_http_request(method, params, expected_response)
    {:reply, :ok, state}
  end

  defcall unload, state: state do
    :meck.unload(Chronos)
    :meck.unload(HttpClient)
    {:reply, :ok, state}
  end

  defcall fake, state: state do
    :meck.expect(Chronos, :now, fn -> {{2014, 10, 14}, {2, 55, 3}} end)
    :meck.expect(HttpClient, :start_link, fn (nil) -> :ok end)
    :meck.expect(HttpClient, :base_url, fn -> "http://localhost:7474" end)

    mock_http_request :get, ["/db/data/"], """
    {
      "extensions" : {
      },
      "node" : "http://localhost:7474/db/data/node",
      "node_index" : "http://localhost:7474/db/data/index/node",
      "relationship_index" : "http://localhost:7474/db/data/index/relationship",
      "extensions_info" : "http://localhost:7474/db/data/ext",
      "relationship_types" : "http://localhost:7474/db/data/relationship/types",
      "batch" : "http://localhost:7474/db/data/batch",
      "cypher" : "http://localhost:7474/db/data/cypher",
      "indexes" : "http://localhost:7474/db/data/schema/index",
      "constraints" : "http://localhost:7474/db/data/schema/constraint",
      "transaction" : "http://localhost:7474/db/data/transaction",
      "node_labels" : "http://localhost:7474/db/data/labels",
      "neo4j_version" : "2.1.5"
    }
    """
    {:reply, :ok, state}
  end

  defcall fake_find_by_id_request(id, expected_response), state: state do
    query = """
    START n=node(#{id})
    RETURN id(n), n
    """
    mock_find_request query, expected_response
    {:reply, :ok, state}
  end

  defcall fake_find_all_request(expected_response), state: state do
    query = """
    MATCH (n:Test:Model:FindMethodTest:Person {})
    RETURN id(n), n
    """
    mock_find_request query, expected_response
    {:reply, :ok, state}
  end

  defcall fake_find_by_properties_request(expected_response), state: state do
    query = """
    MATCH (n:Test:Model:FindMethodTest:Person {age: 30})
    RETURN id(n), n
    """
    mock_find_request query, expected_response
    {:reply, :ok, state}
  end

  defp mock_find_request(query, expected_response) do
    params = ExNeo4j.Helpers.format_statements([{query, %{}}])
    mock_http_request :post, ["/db/data/transaction/commit", params], expected_response
  end

  defp mock_http_request(method, params, expected_response) do
    response = faked_response(List.first(params), expected_response)
    :meck.expect(HttpClient, method, params, response)
  end

  defp faked_response(url, expected_response) do
    %Axe.Response{
      body: expected_response,
      data: nil,
      resp_headers: %{"Access-Control-Allow-Origin" => "*", "Content-Type" => "application/json; charset=UTF-8; stream=true", "Server" => "Jetty(9.0.5.v20130815)", "Transfer-Encoding" => "chunked"},
      status_code: 200,
      url: url}
  end
end
