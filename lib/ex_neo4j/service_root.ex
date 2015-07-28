defmodule ExNeo4j.ServiceRoot do
  HTTPoison.start

  url = Application.get_env(:neo4j, :db) |> Keyword.get(:url)
  auth_token = nil

  %URI{userinfo: user_info} = URI.parse(url)
  if user_info != nil do
    auth_token = Base.encode64(user_info)
    def auth_token, do: unquote(Macro.escape(auth_token))
  else
    def auth_token, do: nil
  end

  headers = []
            |> Keyword.put(:"X-Stream", "true")
            |> Keyword.put(:"Accept", "application/json; charset=UTF-8")
            |> Keyword.put(:"Content-Type", "application/json")
            |> Keyword.put(:"Authorization", "Basic #{auth_token}")

  response = HTTPoison.get!("#{url}/db/data/", headers)
  case response do
    %HTTPoison.Response{status_code: 200, body: body} ->
      root_data = Poison.decode!(body)
      for {k, v} <- root_data, k != "extensions" do
        method_name = String.to_atom(k)
        def unquote(method_name)() do
          unquote(Macro.escape(v))
        end
      end

    %HTTPoison.Response{status_code: 401, body: body} ->
      %{"errors" => [%{"code" => code, "message" => message}|_]} = Poison.decode!(body)
      throw "Failed reaching the neo4j server at url '#{url}' - #{code} - #{message}"

    response ->
      throw "Failed reaching the neo4j server at url: #{url}\nresponse: #{inspect response}"
  end
end
