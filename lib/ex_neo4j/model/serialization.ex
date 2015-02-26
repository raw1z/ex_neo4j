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
        Map.put(%{}, resource_name, serialize_attributes(model))
      end

      def to_json(%__MODULE__{}=model) do
        model |> serialize |> transform_to_json
      end

      def serialize(models) when is_list(models) do
        serialized_models = models |> Enum.map(fn model -> serialize_attributes(model) end)
        Map.put(%{}, Inflex.pluralize(resource_name), serialized_models)
      end

      def to_json(models) when is_list(models) do
        models |> serialize |> transform_to_json
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

