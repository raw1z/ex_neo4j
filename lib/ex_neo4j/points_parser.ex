defmodule ExNeo4j.PointsParser do
  alias ExNeo4j.ServiceRoot.ServiceRootQueryResult

  def parse(%ServiceRootQueryResult{}=result, base_url) do
    rx  = ~r/(?<prefix>http(s)?\:\/\/)((.+)@)?(?<suffix>.+)$/
    captures = Regex.named_captures rx, base_url
    sanitized_base_url = "#{captures["prefix"]}#{captures["suffix"]}"

    result
    |> Map.to_list
    |> Enum.filter(fn {_key, value} -> is_binary(value) and (String.starts_with?(value, "http://") or String.starts_with?(value, "https://")) end)
    |> Enum.map(fn {key, value} -> {key, String.replace(value, sanitized_base_url, "")} end)
    |> Enum.into(Map.new)
  end
end
