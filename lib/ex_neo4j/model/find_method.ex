defmodule ExNeo4j.Model.FindMethod do
  def generate(metadata) do
    quote do
      def find(), do: find %{}

      def find(properties) when is_map(properties) do
        find Map.to_list(properties)
      end

      def find(properties) when is_list(properties) do
        query = ExNeo4j.Model.FindQueryGenerator.query_with_properties(__MODULE__, properties)
        result = ExNeo4j.Db.cypher(query)
        case result do
          {:ok, []} ->
            {:ok, []}

          {:ok, rows} ->
            processor = fn data ->
              model = ExNeo4j.Model.NodeParser.parse(__MODULE__, data)
              unquote generate_after_find_callbacks(metadata)
              model
            end

            {:ok, Enum.map(rows, processor)}

          {:error, resp} ->
            {:nok, resp}
        end
      end

      def find(id) do
        query = ExNeo4j.Model.FindQueryGenerator.query_with_id(__MODULE__, id)
        case ExNeo4j.Db.cypher(query) do
          {:ok, []} ->
            {:ok, nil}

          {:ok, data} ->
            model = ExNeo4j.Model.NodeParser.parse(__MODULE__, data)
            unquote generate_after_find_callbacks(metadata)
            {:ok, model}

          {:error, [%{code: "Neo.ClientError.Statement.EntityNotFound", message: _}]} ->
            {:ok, nil}

          {:error, errors} ->
            {:nok, errors}
        end
      end
    end
  end

  defp generate_after_find_callbacks(metadata) do
    metadata.callbacks
    |> Enum.filter(fn {k,_v} -> k == :after_find end)
    |> Enum.map fn ({_k, callback}) ->
      quote do
        model = unquote(callback)(model)
      end
    end
  end
end
