defmodule ExNeo4j.Model.SaveMethod do
  def generate(metadata) do
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
        {query, query_params} = ExNeo4j.Model.SaveQueryGenerator.query_for_model(model, __MODULE__)

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
