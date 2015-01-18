defmodule ExNeo4j.Model.UpdateMethod do
  def generate(_metadata) do
    quote do
      def update_attributes(model, attributes) do
        formatter = fn
          {k,v} when is_binary(k) -> {String.to_atom(k), v}
          {k,v} -> {k,v}
        end

        attributes = attributes
          |> Enum.map(formatter)
          |> Enum.into(%{})

        Map.merge(model, attributes)
      end

      def update_attribute(model, name, value) do
        Map.put(model, name, value)
      end
    end
  end
end

