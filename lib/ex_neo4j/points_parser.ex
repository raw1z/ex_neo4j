defmodule ExNeo4j.PointsParser do
  def parse(attributes, base_url) when is_map(attributes) do
    attributes
    |> Map.to_list
    |> Enum.map(fn {key, value} -> {String.to_atom(key), value} end)
    |> Enum.filter(fn {_key, value} -> is_binary(value) and (String.starts_with?(value, "http://") or String.starts_with?(value, "https://")) end)
    |> Enum.map(fn {key, value} -> {key, String.replace(value, base_url, "")} end)
    |> Enum.into(Map.new)
  end
end
