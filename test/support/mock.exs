defmodule Mock do
  def init_mocks do
    mock_module Timex.Date
    :meck.expect(Timex.Date, :now, fn ->
      %Timex.DateTime{calendar: :gregorian, day: 14, hour: 2, minute: 55, month: 10,
       ms: 0, second: 3,
       timezone: %Timex.TimezoneInfo{abbreviation: "UTC", from: :min,
        full_name: "UTC", offset_std: 0, offset_utc: 0, until: :max}, year: 2014}
    end)
    mock_module ExNeo4j.Db, [:unstick, :passthrough]
    mock_module ExNeo4j.HttpClient, [:unstick, :passthrough]
  end

  def unload_mocks do
    :meck.unload(ExNeo4j.Db)
    :meck.unload(ExNeo4j.HttpClient)
    :meck.unload(Timex.Date)
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
