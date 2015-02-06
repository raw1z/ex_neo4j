defmodule ExNeo4j.HttpClient do
  use HTTPoison.Base

  def process_request_headers(headers) do
    headers
    |> Keyword.put(:"X-Stream", "true")
    |> Keyword.put(:"Accept", "application/json; charset=UTF-8")
    |> Keyword.put(:"Content-Type", "application/json")
  end
end

