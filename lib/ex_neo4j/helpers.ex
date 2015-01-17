defmodule ExNeo4j.Helpers do
  def format_statements(queries) when is_list(queries) do
    do_format_statements(queries, [])
  end

  def do_format_statements([], acc), do: to_json(%{statements: Enum.reverse(acc)})
  def do_format_statements([{query, params}|tail], acc) do
    statement = format_statement(query, params)
    do_format_statements(tail, [statement|acc])
  end

  def format_statement(query, params) do
    statement = %{ statement: query }
    if Map.size(params) > 0 do
      statement = Map.merge(statement, %{parameters: params})
    end
    statement
  end

  def to_json(value, options \\ []) do
    Poison.Encoder.encode(value, options) |> IO.iodata_to_binary
  end
end
