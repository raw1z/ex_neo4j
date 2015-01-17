defmodule ExNeo4j.Model.Metadata do
  defstruct fields: nil#,
            # before_save_callbacks: nil,
            # before_create_callbacks: nil,
            # after_save_callbacks: nil,
            # after_create_callbacks: nil,
            # after_find_callbacks: nil,
            # validation_functions: nil,
            # functions: nil,
            # relationships: nil

  def new(module) do
    fields = Module.get_attribute(module, :fields) |> expand_fields
    # before_save_callbacks = Module.get_attribute(module, :before_save)
    # before_create_callbacks = Module.get_attribute(module, :before_create)
    # after_save_callbacks = Module.get_attribute(module, :after_save)
    # after_create_callbacks = Module.get_attribute(module, :after_create)
    # after_find_callbacks = Module.get_attribute(module, :after_find)
    # validation_functions = Module.get_attribute(module, :validation_functions)
    # functions = Module.get_attribute(module, :functions)
    # relationships = Module.get_attribute(module, :relationships) |> expand_relationships

    %__MODULE__{
      fields: fields#,
      # before_save_callbacks: before_save_callbacks,
      # before_create_callbacks: before_create_callbacks,
      # after_save_callbacks: after_save_callbacks,
      # after_create_callbacks: after_create_callbacks,
      # after_find_callbacks: after_find_callbacks,
      # validation_functions: validation_functions,
      # functions: functions,
      # relationships: relationships
    }
  end

  defp expand_fields(fields) do
    fields
    |> Enum.map(fn {name, attributes} -> ExNeo4j.Model.Field.new(name, attributes) end)
    |> Enum.sort(&(&1.name < &2.name))
  end

  # defp expand_relationships(relationships) do
  #   Enum.map relationships, fn {name, related_model} -> ExNeo4j.Model.Relationship.new(name, related_model) end
  # end
end
