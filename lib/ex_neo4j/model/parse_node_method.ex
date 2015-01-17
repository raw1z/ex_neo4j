defmodule ExNeo4j.Model.ParseNodeMethod do
  def generate(metadata) do
    quote do
      unquote generate_parse_node(metadata)
    end
  end

  defp generate_parse_node(metadata) do
    relationships = for relationship <- metadata.relationships do
      module = relationship.related_model
      map = {:%, [], [module, {:%{}, [], []}]}
      {Macro.escape(relationship), {map, module}}
    end
    |> Enum.filter(fn x -> x != nil end)

    if Enum.count(relationships) == 0 do
      quote do
        defp parse_node(data) do
          id = data["id(n)"]
          properties = data["n"]
          func = &Map.merge(%__MODULE__{id: id}, &1)
          properties
            |> Enum.map(fn {k,v} -> {String.to_atom(k), v} end)
            |> Enum.into(%{})
            |> func.()
        end
      end
    else
      quote do
        defp get_related_model_attributes(data, related_model_name) do
          tag = Atom.to_string(related_model_name)
          attributes = Map.get(data, tag)

          if attributes == nil do
            %{}
          else
            idTag = "id(#{tag})"
            attributes
              |> Map.put("id", Map.get(data, idTag))
              |> Enum.map(fn {k, v} -> {String.to_atom(k), v} end)
              |> Enum.into(%{})
          end
        end

        defp parse_node(data) do
          id = data["id(n)"]
          properties = data["n"]
          func = &Map.merge(%__MODULE__{id: id}, &1)
          model = properties
            |> Enum.map(fn {k,v} -> {String.to_atom(k), v} end)
            |> Enum.into(%{})
            |> func.()

          relationships = Enum.map(unquote(relationships), fn
            {relationship, {map, module}} ->
              attributes = get_related_model_attributes(data, relationship.related_model)
              {relationship.related_model, {Map.merge(map, attributes), module}}
          end)
          |> Enum.into(%{})

          %__MODULE__{model | relationships: relationships}
        end
      end
    end
  end
end
