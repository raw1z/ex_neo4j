defmodule ExNeo4j.Model.Field do
  defstruct name: nil,
            required: false,
            unique: false,
            default: nil,
            transient: false,
            type: :string,
            format: nil,
            relationship: false

  def new(name, attributes) when is_list(attributes), do: new(name, Enum.into(attributes, %{}))
  def new(name, attributes) do
    Map.merge %__MODULE__{name: name}, attributes
  end
end
