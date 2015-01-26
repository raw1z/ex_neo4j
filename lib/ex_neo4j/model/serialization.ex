defmodule ExNeo4j.Model.Serialization do
  def generate(metadata) do
    serialized_fields = metadata.fields
                        |> Enum.filter(fn field -> field.name == :id or field.name == :errors or field.transient == false end)
                        |> Enum.map(fn field -> Macro.escape(field) end)
    quote do
      def serialize_attributes(%__MODULE__{}=model) do
        unquote(serialized_fields)
        |> Enum.map(fn field -> {attribute_label(model, field), attribute_value(model, field.name)} end)
        |> Enum.into(Map.new)
      end

      def serialize(%__MODULE__{}=model) do
        data = Map.put(%{}, resource_name, serialize_attributes(model))

        if model.relationships do
          related_models_serialization = Enum.map(model.relationships, fn
            {related_model_name, {related_model, related_model_module}} ->
              func = fn {result, _} -> {related_model_name |> Atom.to_string |> Inflex.pluralize, [result]} end

              {{:., [], [Macro.escape(related_model_module), :serialize_attributes]}, [], [Macro.escape(related_model)]}
              |> Code.eval_quoted
              |> func.()
          end)
          |> Enum.into(%{})

          data = Map.merge(data, related_models_serialization)
        end

        data
      end

      def to_json(%__MODULE__{}=model) do
        model |> serialize |> transform_to_json
      end

      def serialize(models) when is_list(models) do
        serialized_models = models |> Enum.map(fn model -> serialize_attributes(model) end)
        data = Map.put(%{}, Inflex.pluralize(resource_name), serialized_models)

        merger = &Map.merge(data, &1)
        Enum.map(models, fn model ->
          if model.relationships do
            related_models_serialization = Enum.map(model.relationships, fn
              {related_model_name, {related_model, related_model_module}} ->
                func = fn {result, _} -> {related_model_name, result} end

                {{:., [], [Macro.escape(related_model_module), :serialize_attributes]}, [], [Macro.escape(related_model)]}
                |> Code.eval_quoted
                |> func.()
            end)
            |> Enum.into(%{})
          end
        end)
        |> Enum.filter(fn x -> x != nil end)
        |> format_related_model_serializations()
        |> merger.()
      end

      def to_json(models) when is_list(models) do
        models |> serialize |> transform_to_json
      end

      defp format_related_model_serializations(serializations) do
        Enum.reduce(serializations, %{}, fn(serialization, acc) ->
          merger = &Map.merge(acc, &1, fn k, v1, v2 -> [v2|v1] end)
          serialization
              |> Enum.map(fn {k,v} -> {k, [v]} end)
              |> Enum.into(%{})
              |> merger.()
        end)
        |> Enum.map(fn {k,v} -> {k |> Atom.to_string |> Inflex.pluralize, List.flatten(v)} end)
        |> Enum.into(%{})
      end

      defp attribute_label(model, field) do
        attribute_name = Atom.to_string(field.name)
        Inflex.camelize(attribute_name, :lower)
      end

      defp attribute_value(model, attribute_name) do
        value = Map.get(model, attribute_name)
        if attribute_name == :errors and value != nil do
          format_error_key = fn k -> k |> Inflex.camelize(:lower) |> String.to_atom end
          value = value |> Enum.map(fn {k,v} -> {format_error_key.(k), v} end) |> Enum.into(%{})
        end
        value
      end

      defp resource_name do
        "#{__MODULE__}"
        |> String.split(".")
        |> List.last
        |> String.downcase
        |> Inflex.singularize
      end

      defp transform_to_json(value, options \\ []) do
        Poison.Encoder.encode(value, options) |> IO.iodata_to_binary
      end
    end
  end
end

