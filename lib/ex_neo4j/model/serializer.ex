defmodule ExNeo4j.Model.Serializer do
  def serialize(module, models) when is_list(models) do
    serialized_models = models |> Enum.map(&(serialize_attributes(module, &1)))
    Map.put(%{}, Inflex.pluralize(resource_name(module)), serialized_models)
  end

  def serialize(module, model) do
    Map.put(%{}, resource_name(module), serialize_attributes(module, model))
  end

  def to_json(module, models) when is_list(models) do
    serialize(module, models) |> transform_to_json
  end

  def to_json(module, model) do
    serialize(module, model) |> transform_to_json
  end

  def serialize_attributes(module, model) do
    serialized_fields = serialized_fields(module)
    relationship_fields = relationship_fields(module)
    keys = Map.keys(model)

    Enum.reduce keys, %{}, fn (key, acc) ->
      attribute_label = attribute_label(key)

      if Enum.find(serialized_fields, &(&1.name == key)) do
        Map.put acc, attribute_label, attribute_value(model, key)
      else
        if field = Enum.find(relationship_fields, &(&1.name == key)) do
          relationship = Enum.find(module.metadata.relationships, &(field_name_for_relationship(&1) == field.name))
          related_instances = Map.get(model, key) || []
          Map.put acc, attribute_label, Enum.map(related_instances, &__MODULE__.serialize_attributes(relationship.related_model, &1))
        else
          acc
        end
      end
    end
  end

  defp attribute_label(key) do
    key |> Atom.to_string |> Inflex.camelize(:lower)
  end

  defp attribute_value(model, key) do
    value = Map.get(model, key)
    if key == :errors and value != nil do
      format_error_key = fn k -> k |> Inflex.camelize(:lower) |> String.to_atom end
      value = value |> Enum.map(fn {k,v} -> {format_error_key.(k), v} end) |> Enum.into(%{})
    end
    value
  end

  defp resource_name(module) do
    "#{module}"
    |> String.split(".")
    |> List.last
    |> String.downcase
    |> Inflex.singularize
  end

  defp transform_to_json(value, options \\ []) do
    Poison.Encoder.encode(value, options) |> IO.iodata_to_binary
  end

  defp serialized_fields(module) do
    module.metadata.fields
    |> Enum.filter(&(&1.name == :id or &1.name == :errors or (&1.transient == false and &1.private == false)))
    |> Enum.filter(&(&1.relationship == false))
  end

  defp relationship_fields(module) do
    module.metadata.fields
    |> Enum.filter(&(&1.relationship == true))
  end

  defp field_name_for_relationship(relationship) do
    relationship.name |> Atom.to_string |> String.downcase |> String.to_atom
  end
end
