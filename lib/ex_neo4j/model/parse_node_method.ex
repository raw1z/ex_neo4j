defmodule ExNeo4j.Model.ParseNodeMethod do
  def generate(_metadata) do
    quote do
      unquote generate_parse_node()
    end
  end

  defp generate_parse_node() do
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
  end
end
