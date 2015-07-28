defmodule ExNeo4j.HttpClient do
  use HTTPoison.Base
  alias ExNeo4j.ServiceRoot

  def process_request_headers(headers) do
    headers
    |> Keyword.put(:"X-Stream", "true")
    |> Keyword.put(:"Accept", "application/json; charset=UTF-8")
    |> Keyword.put(:"Content-Type", "application/json")
    |> apply_authentication
  end

  defp apply_authentication(headers) do
    if ServiceRoot.auth_token == nil do
      headers
    else
      Keyword.put(headers, :"Authorization", "Basic #{ServiceRoot.auth_token}")
    end
  end
end

