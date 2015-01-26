defmodule ExNeo4j.Model.FindMethod do
  def generate(metadata) do
    quote do
      def find(), do: find %{}

      def find(properties) when is_map(properties) do
        find Map.to_list(properties)
      end

      def find(properties) when is_list(properties) do
        query = find_query(properties)
        result = ExNeo4j.Db.cypher(query)
        case result do
          {:ok, []} ->
            {:ok, []}

          {:ok, rows} ->
            processor = fn data ->
              model = data |> parse_node
              # unquote generate_after_find_callbacks(metadata.after_find_callbacks)
              model
            end
            {:ok, Enum.map(rows, processor)}

          {:error, resp} ->
            {:nok, resp}
        end
      end

      def find(id) do
        query = find_by_id_query(id)
        case ExNeo4j.Db.cypher(query) do
          {:ok, []} ->
            {:ok, nil}

          {:ok, [data|_]} ->
            model = parse_node(data)
            # unquote generate_after_find_callbacks(metadata.after_find_callbacks)
            {:ok, model}

          {:error, [%{code: "Neo.ClientError.Statement.EntityNotFound", message: _}]} ->
            {:ok, nil}

          {:error, errors} ->
            {:nok, errors}
        end
      end

      unquote generate_find_query(metadata)
      unquote generate_find_by_id_query(metadata)
    end
  end

  defp generate_find_query(metadata) do
    relationships = for relationship <- metadata.relationships do
      corresponding_field = metadata.fields
                            |> Enum.filter(fn field -> field.relationship == true and field.name == relationship.related_model end)
                            |> List.first

      if corresponding_field != nil do
        Macro.escape {relationship, corresponding_field}
      end
    end
    |> Enum.filter(fn x -> x != nil end)

    if Enum.count(relationships) == 0 do
      quote do
        def find_query(properties) do
          query_params = properties
                          |> Enum.map(fn {k,v} -> "#{k}: #{inspect(v)}" end)
                          |> Enum.join(", ")

          """
          MATCH (n:#{@label} {#{query_params}})
          RETURN id(n), n
          """
        end
      end
    else
      quote do
        def find_query(properties) do
          relationships = unquote(relationships)
          match_clauses = relationships
                          |> Enum.map(fn {relationship, field} -> "OPTIONAL MATCH (n)-[:#{relationship.name}]->(#{relationship.related_model})" end)
                          |> Enum.join("\n")

          return_clauses = relationships
                          |> Enum.map(fn {relationship, field} -> [ relationship.related_model, "id(#{relationship.related_model})" ] end)
                          |> List.flatten
                          |> Enum.join(", ")

          query_params = properties
                          |> Enum.map(fn {k,v} -> "#{k}: #{inspect(v)}" end)
                          |> Enum.join(", ")

          """
          MATCH (n:#{@label} {#{query_params}})
          #{match_clauses}
          RETURN id(n), n, #{return_clauses}
          """
        end
      end
    end
  end

  defp generate_find_by_id_query(metadata) do
    relationships = for relationship <- metadata.relationships do
      corresponding_field = metadata.fields
                            |> Enum.filter(fn field -> field.relationship == true and field.name == relationship.related_model end)
                            |> List.first

      if corresponding_field != nil do
        Macro.escape {relationship, corresponding_field}
      end
    end
    |> Enum.filter(fn x -> x != nil end)

    if Enum.count(relationships) == 0 do
      quote do
        defp find_by_id_query(id) do
          """
          START n=node(#{id})
          RETURN id(n), n
          """
        end
      end
    else
      quote do
        defp find_by_id_query(id) do
          relationships = unquote(relationships)
          match_clauses = relationships
                          |> Enum.map(fn {relationship, field} -> "OPTIONAL MATCH (n)-[:#{relationship.name}]->(#{relationship.related_model})" end)
                          |> Enum.join("\n")

          return_clauses = relationships
                          |> Enum.map(fn {relationship, field} -> [ relationship.related_model, "id(#{relationship.related_model})" ] end)
                          |> List.flatten
                          |> Enum.join(", ")

          """
          START n=node(#{id})
          #{match_clauses}
          RETURN id(n), n, #{return_clauses}
          """
        end
      end
    end
  end
end
