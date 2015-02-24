defmodule ExNeo4j.Model.Metadata do
  defstruct fields: nil,
            relationships: nil,
            callbacks: nil,
            # validation_functions: nil,
            functions: nil

  def new(module) do
    fields = Module.get_attribute(module, :fields) |> expand_fields
    relationships = Module.get_attribute(module, :relationships) |> expand_relationships
    callbacks = Module.get_attribute(module, :callbacks)
    # validation_functions = Module.get_attribute(module, :validation_functions)
    functions = Module.get_attribute(module, :functions)

    %__MODULE__{
      fields: fields,
      relationships: relationships,
      callbacks: callbacks,
      # validation_functions: validation_functions,
      functions: functions
    }
  end

  defp expand_fields(fields) do
    fields
    |> Enum.map(fn {name, attributes} -> ExNeo4j.Model.Field.new(name, attributes) end)
    |> Enum.sort(&(&1.name < &2.name))
  end

  defp expand_relationships(relationships) do
    relationships
    |> Enum.map(fn {name, related_model} -> ExNeo4j.Model.Relationship.new(name, related_model) end)
    |> Enum.sort(&(&1.name < &2.name))
  end
end
