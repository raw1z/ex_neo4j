defmodule ExNeo4j.Model.SaveMethod do
  def generate(metadata) do
    persisted_fields = metadata.fields
                        |> Enum.filter(fn field -> field.transient == false end)
                        |> Enum.map(fn field -> field.name end)

    quote do
      def save(%__MODULE__{validated: false, errors: nil}=model) do
        # if model.id == nil do
        #   unquote generate_before_create_callbacks(metadata.before_create_callbacks)
        # end

        # unquote generate_before_save_callbacks(metadata.before_save_callbacks)
        # model = validate(model)
        model = %__MODULE__{model | validated: true, errors: []}
        save(model)
      end
      def save(%__MODULE__{validated: true, errors: []}=model), do: do_save(model)
      def save(%__MODULE__{}=model), do: {:nok, nil, model}

      defp do_save(%__MODULE__{}=model) do
        is_new_record = ( model.id == nil )

        query = unquote(generate_query(metadata))
        properties = unquote(persisted_fields)
                      |> Enum.map(fn name -> {name, Map.get(model, name)} end)
                      |> Enum.filter(fn {_k,v} -> v != nil end)
                      |> Enum.into Map.new

        properties = Map.put(properties, "updated_at", current_datetime)

        if is_new_record do
          properties = properties
                        |> Map.put("created_at", properties["updated_at"])
        end

        query_params = %{
          properties: properties
        }

        case ExNeo4j.Db.cypher(query, query_params) do
          {:ok, [data|_]} ->
            model = parse_node(data)

            # if is_new_record do
            #   unquote generate_after_create_callbacks(metadata.after_create_callbacks)
            # end

            # unquote generate_after_save_callbacks(metadata.after_save_callbacks)

            {:ok, model}
          {:error, resp} ->
            {:nok, resp, model}
        end
      end

      defp current_datetime do
        Chronos.Formatter.strftime(Chronos.now, "%Y-%0m-%0d %H:%M:%S +0000")
      end
    end
  end

  defp generate_query(metadata) do
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
        """
        CREATE (n:#{@label} { properties })
        RETURN id(n), n
        """
      end
    else
      quote do
        relationships = unquote(relationships)
        start_clauses = relationships
                        |> Enum.filter(fn {relationship, field} -> Map.get(model, field.name) != nil end)
                        |> Enum.map(fn {relationship, field} -> "#{relationship.related_model}=node(#{Map.get(model, field.name)})" end)
                        |> Enum.join(", ")

        relationship_clauses = relationships
                        |> Enum.filter(fn {relationship, field} -> Map.get(model, field.name) != nil end)
                        |> Enum.map(fn {relationship, field} -> "CREATE (n)-[:#{relationship.name}]->(#{relationship.related_model})" end)
                        |> Enum.join("\n")

        return_clauses = relationships
                        |> Enum.filter(fn {relationship, field} -> Map.get(model, field.name) != nil end)
                        |> Enum.map(fn {relationship, field} -> [ relationship.related_model, "id(#{relationship.related_model})" ] end)
                        |> List.flatten
                        |> Enum.join(", ")


        if String.length(start_clauses) > 0 and String.length(relationship_clauses) > 0 and String.length(return_clauses) > 0 do
          """
          START #{start_clauses}
          CREATE (n:#{@label} { properties })
          #{relationship_clauses}
          RETURN id(n), n, #{return_clauses}
          """
        else
          """
          CREATE (n:#{@label} { properties })
          RETURN id(n), n
          """
        end
      end
    end
  end

  # defp generate_before_save_callbacks(callbacks) do
  #   Enum.map callbacks, fn (callback) ->
  #     quote do
  #       model = unquote(callback)(model)
  #     end
  #   end
  # end

  # defp generate_before_create_callbacks(callbacks) do
  #   Enum.map callbacks, fn (callback) ->
  #     quote do
  #       model = unquote(callback)(model)
  #     end
  #   end
  # end

  # defp generate_after_save_callbacks(callbacks) do
  #   Enum.map callbacks, fn (callback) ->
  #     quote do
  #       model = unquote(callback)(model)
  #     end
  #   end
  # end

  # defp generate_after_create_callbacks(callbacks) do
  #   Enum.map callbacks, fn (callback) ->
  #     quote do
  #       model = unquote(callback)(model)
  #     end
  #   end
  # end
end
