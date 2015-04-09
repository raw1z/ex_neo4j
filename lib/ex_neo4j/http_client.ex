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

  def apply_authentication(headers) do
    if ServiceRoot.user_info == nil do
      headers
    else
      token = Base.encode64(ServiceRoot.user_info)
      Keyword.put(headers, :"Authorization",  "Basic #{token}")
    end
  end
end

