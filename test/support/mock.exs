defmodule Mock do
  def init_mocks do
    mock_module Chronos
    :meck.expect(Chronos, :now, fn -> {{2014, 10, 14}, {2, 55, 3}} end)
    mock_module ExNeo4j.Db, [:unstick, :passthrough]
    mock_module ExNeo4j.HttpClient, [:unstick, :passthrough]
  end

  def unload_mocks do
    :meck.unload(ExNeo4j.Db)
    :meck.unload(ExNeo4j.HttpClient)
    :meck.unload(Chronos)
  end

  defp mock_module(mod, params \\ []) do
    already_mocked = Process.list
      |> Enum.map(&Process.info/1)
      |> Enum.filter(&(&1 != nil))
      |> Enum.map(&(Keyword.get(&1, :registered_name)))
      |> Enum.filter(&(&1 == :"#{mod}_meck"))
      |> Enum.any?

    unless already_mocked, do: do_mock_module(mod, params)
  end

  defp do_mock_module(mod, []), do: :meck.new(mod)
  defp do_mock_module(mod, params), do: :meck.new(mod, params)

  defmacro enable_mock(do: block) do
    quote do
      init_mocks
      unquote(block)
      unload_mocks
    end
  end

  defmacro cypher_returns(response, for_query: query) do
    quote bind_quoted: [query: query, response: response] do
      :meck.expect(ExNeo4j.Db, :cypher, fn
        (query) -> response
      end)
    end
  end

  defmacro cypher_returns(response, for_query: query, with_params: params) do
    quote bind_quoted: [query: query, response: response, params: params] do
      :meck.expect(ExNeo4j.Db, :cypher, fn
        (query, params) -> response
      end)
    end
  end

  defmacro http_client_returns(response, for_query: query, with_params: params) do
    quote bind_quoted: [query: query, params: params, response: response] do
      request_body = ExNeo4j.Helpers.format_statements([{query, params}])
      :meck.expect(ExNeo4j.HttpClient, :post!, fn
        ("http://localhost:7474/db/data/transaction/commit", body=request_body) ->
          %{ body: response }
      end)
    end
  end

  defmacro http_client_returns(response, for_queries: queries, with_params: params) do
    quote bind_quoted: [queries: queries, params: params, response: response] do
      request_body = ExNeo4j.Helpers.format_statements(Enum.zip(queries, params))
      :meck.expect(ExNeo4j.HttpClient, :post!, fn
        ("http://localhost:7474/db/data/transaction/commit", body=request_body) ->
          %{ body: response }
      end)
    end
  end
end
