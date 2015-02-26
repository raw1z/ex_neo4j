defmodule ExNeo4j.Model.SaveMethod do
  def generate(metadata) do
    persisted_fields = metadata.fields
                        |> Enum.filter(fn field -> field.transient == false end)
                        |> Enum.map(fn field -> field.name end)

    quote do
      def save(%__MODULE__{validated: false, errors: nil}=model) do
        model = validate(model)

        unquote generate_callback_calls(metadata, :before_save)
        if model.id == nil do
          unquote generate_callback_calls(metadata, :before_create)
        else
          unquote generate_callback_calls(metadata, :before_update)
        end

        save(model)
      end

      def save(%__MODULE__{validated: true, errors: nil}=model), do: do_save(model)
      def save(%__MODULE__{}=model), do: {:nok, nil, model}

      defp do_save(%__MODULE__{}=model) do
        is_new_record = ( model.id == nil )
        {query, query_params} = if is_new_record, do: query_for_new_model(model), else: query_for_existing_model(model)

        case ExNeo4j.Db.cypher(query, query_params) do
          {:ok, []} ->
            {:ok, []}

          {:ok, [data|_]} ->
            model = parse_node(data)

            unquote generate_callback_calls(metadata, :after_save)
            if is_new_record do
              unquote generate_callback_calls(metadata, :after_create)
            else
              unquote generate_callback_calls(metadata, :after_update)
            end

            {:ok, model}

          {:error, resp} ->
            {:nok, resp, model}
        end
      end

      defp current_datetime do
        Chronos.Formatter.strftime(Chronos.now, "%Y-%0m-%0d %H:%M:%S +0000")
      end

      defp query_for_new_model(model) do
        query = """
        CREATE (n:#{@label} { properties })
        RETURN id(n), n
        """

        properties = unquote(persisted_fields)
                      |> Enum.map(fn name -> {name, Map.get(model, name)} end)
                      |> Enum.filter(fn {_k,v} -> v != nil end)
                      |> Enum.into Map.new

        date = current_datetime
        properties = properties
          |> Map.put(:updated_at, date)
          |> Map.put(:created_at, date)

        query_params = %{
          properties: properties
        }

        {query, query_params}
      end

      defp query_for_existing_model(model) do
        properties = unquote(persisted_fields)
                      |> Enum.filter(&(&1 != :id))
                      |> Enum.map(fn name -> {name, Map.get(model, name)} end)
                      |> Enum.filter(fn {_k,v} -> v != nil end)
                      |> Enum.into Map.new

        properties = properties
                      |> Map.put("updated_at", current_datetime)
                      |> Enum.filter(fn {_k,v} -> v != nil end)
                      |> Enum.map(fn {k,v} -> "n.#{k} = #{inspect v}" end)

        query = """
        START n=node(#{model.id})
        SET #{Enum.join(properties, ", ")}
        """

        {query, %{}}
      end
    end
  end

  defp generate_callback_calls(metadata, kind) do
    metadata.callbacks
    |> Enum.filter(fn {k, _v} -> k == kind end)
    |> Enum.map fn {_k, callback} ->
      quote do
        model = unquote(callback)(model)
      end
    end
  end
end
