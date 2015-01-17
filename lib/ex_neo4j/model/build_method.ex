defmodule ExNeo4j.Model.BuildMethod do
  def generate(metadata) do
    quote do
      def build(params) when is_list(params) do
        params
          |> Enum.map(fn {k,v} -> {Atom.to_string(k), v} end)
          |> Enum.into(%{})
          |> build
      end

      unquote generate_for_required_field(metadata.fields)
      unquote generate_for_each_field(metadata.fields)

      def build, do: %__MODULE__{}

      def build(params) when is_map(params) do
        mapper = fn
          {k,v} when is_binary(k) -> {String.to_atom(k), v}
          {k,v} when is_atom(k) -> {k, v}
          _ -> nil
        end

        params = params
        |> Enum.map(mapper)
        |> Enum.filter(&(&1 != nil))
        |> Enum.into(%{})

        Map.merge(%__MODULE__{}, params)
      end
    end
  end

  defp generate_for_each_field(fields) do
    fields
    |> Enum.filter(fn field -> field.required == true end)
    |> Enum.map(fn field -> {Atom.to_string(field.name), Macro.var(field.name, __MODULE__)} end)
    |> Enum.map fn field ->
      function_args = {:%{}, [], [field]}
      quote do
        def build(unquote(function_args)=attributes) do
          attributes = attributes
          |> Enum.map(fn {k,v} -> {String.to_atom(k), v} end)
          |> Enum.into(Map.new)

          Map.merge %__MODULE__{}, attributes
        end
      end
    end
  end

  defp generate_for_required_field(fields) do
    required_fields = fields
                      |> Enum.filter(fn field -> field.required == true end)
                      |> Enum.map(fn field -> {Atom.to_string(field.name), Macro.var(field.name, __MODULE__)} end)
    function_args = {:%{}, [], required_fields}

    quote do
      def build(unquote(function_args) = attributes) do
        attributes = attributes
        |> Enum.map(fn {k,v} -> {String.to_atom(k), v} end)
        |> Enum.into(Map.new)
        Map.merge %__MODULE__{}, attributes
      end
    end
  end
end
