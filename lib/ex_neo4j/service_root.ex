defmodule ExNeo4j.ServiceRoot do
  HTTPoison.start

  url = case Application.get_env(:neo4j, :db) do
    nil ->
      "http://localhost:7474"
    config  ->
      Keyword.get(config, :url)
  end

  %URI{userinfo: user_info} = URI.parse(url)
  if user_info != nil do
    def user_info do
      unquote(Macro.escape(user_info))
    end
  end

  response = HTTPoison.get!("#{url}/db/data/")
  case response do
    %HTTPoison.Response{status_code: 200, body: body} ->
      root_data = Poison.decode!(body)
      for {k, v} <- root_data, k != "extensions" do
        method_name = String.to_atom(k)
        def unquote(method_name)() do
          unquote(Macro.escape(v))
        end
      end

    _ ->
      throw "Failed reaching the neo4j server at url: #{url}"
  end
end
