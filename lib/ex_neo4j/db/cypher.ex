defmodule ExNeo4j.Db.Cypher do
  defmacro __using__(_) do
    quote do
      alias ExNeo4j.ServiceRoot
      alias ExNeo4j.HttpClient
      alias ExNeo4j.Helpers

      defmodule CypherQueryResult do
        defstruct results: [], errors: []
      end

      @doc """
      run a cypher query inside a transaction and returns the result
      """
      def cypher(query) when is_binary(query) do
        do_cypher(query, %{})
      end

      @doc """
      run a cypher query with some parameters inside a transaction and returns the result
      """
      def cypher(query, params) when is_list(params) do
        do_cypher(query, Enum.into(params, %{}))
      end

      def cypher(query, params) when is_map(params) do
        do_cypher(query, params)
      end

      @doc """
      run multiple cypher queries inside a transaction
      """
      def cypher(queries) when is_list(queries) do
        do_cypher(queries)
      end

      defp do_cypher(query, params) when is_map(params) do
        query_point = "#{ServiceRoot.transaction}/commit"
        response = HttpClient.post! query_point, Helpers.format_statements([{query, params}])
        result = Poison.decode!(response.body, as: CypherQueryResult)
        case result do
          %CypherQueryResult{errors: [], results: []} ->
            {:ok, []}
          %CypherQueryResult{errors: [], results: results} ->
            {:ok, results |> List.first |> format_cypher_response}
          %CypherQueryResult{errors: errors} ->
            formatter = &Enum.map(&1, fn {k,v} -> {String.to_atom(k), v} end)
            formatted_errors = errors
              |> Enum.map(&formatter.(&1))
              |> Enum.map(&Enum.into(&1, %{}))
            {:error, formatted_errors }
        end
      end

      defp do_cypher(queries) when is_list(queries) do
        query_point = "#{ServiceRoot.transaction}/commit"
        response = HttpClient.post! query_point, Helpers.format_statements(queries)
        result = Poison.decode!(response.body, as: CypherQueryResult)
        case result do
          %CypherQueryResult{errors: [], results: []} ->
            {:ok, []}
          %CypherQueryResult{errors: [], results: results} ->
            {:ok, results |> Enum.map(&format_cypher_response(&1))}
          %CypherQueryResult{errors: errors} ->
            {:error, errors}
        end
      end

      defp format_cypher_response(response) do
        columns = response["columns"]
        response["data"]
          |> Enum.map(fn data -> Map.get(data, "row") end)
          |> Enum.map(fn data -> Enum.zip(columns, data) end)
          |> Enum.map(fn data -> Enum.into(data, %{}) end)
      end
    end
  end
end
