defmodule ExNeo4j.HttpClient do
  use ExActor.GenServer, export: :neo4j_http_client

  defmodule State do
    defstruct url: nil
  end

  defmodule Api do
    use Jazz

    Enum.map [:get, :post, :head, :put, :patch, :delete], fn method ->
      def unquote(method)(url), do: unquote(method)(url, %{}, "")
      def unquote(method)(url, headers) when is_map(headers), do: unquote(method)(url, headers, "")
      def unquote(method)(url, body) when is_binary(body), do: unquote(method)(url, %{}, body)
      def unquote(method)(url, headers, body) do
        headers = process_request_headers(headers)
        case Axe.Client.unquote(method)(url, headers, body) do
          %Axe.Worker.Response{}=response ->
            %Axe.Worker.Response{response | body: parse_json_body(response.body)}
          error ->
            error
        end
      end
    end

    def process_request_headers(headers) do
      [{"X-Stream", "true"},{"Accept", "application/json; charset=UTF-8"},{"Content-Type", "application/json"}]
      |> Enum.into(%{})
      |> Map.merge(headers)
    end

    defp parse_json_body(""), do: nil
    defp parse_json_body(body), do: JSON.decode!(body)
  end


  definit url do
    {:ok, _} = Axe.Worker.start
    %State{url: url || "http://localhost:7474"} |> initial_state
  end

  defcall base_url, state: %State{url: url}, do: url |> reply

  defcall get(url, headers, options)         , state: state, do: Api.get(format_url(state, url), headers, options) |> reply
  defcall get(url, headers)                  , state: state, do: Api.get(format_url(state, url), headers) |> reply
  defcall get(url)                           , state: state, do: Api.get(format_url(state, url)) |> reply

  defcall put(url, body, headers, options)   , state: state, do: Api.put(format_url(state, url), body, headers, options) |> reply
  defcall put(url, body, headers)            , state: state, do: Api.put(format_url(state, url), body, headers) |> reply
  defcall put(url, body)                     , state: state, do: Api.put(format_url(state, url), body) |> reply

  defcall head(url, headers, options)        , state: state, do: Api.head(format_url(state, url), headers, options) |> reply
  defcall head(url, headers)                 , state: state, do: Api.head(format_url(state, url), headers) |> reply
  defcall head(url)                          , state: state, do: Api.head(format_url(state, url)) |> reply

  defcall post(url, body, headers, options)  , state: state, do: Api.post(format_url(state, url), body, headers, options) |> reply
  defcall post(url, body, headers)           , state: state, do: Api.post(format_url(state, url), body, headers) |> reply
  defcall post(url, body)                    , state: state, do: Api.post(format_url(state, url), body) |> reply

  defcall patch(url, body, headers, options) , state: state, do: Api.patch(format_url(state, url), body, headers, options) |> reply
  defcall patch(url, body, headers)          , state: state, do: Api.patch(format_url(state, url), body, headers) |> reply
  defcall patch(url, body)                   , state: state, do: Api.patch(format_url(state, url), body) |> reply

  defcall delete(url, headers, options)      , state: state, do: Api.delete(format_url(state, url), headers, options) |> reply
  defcall delete(url, headers)               , state: state, do: Api.delete(format_url(state, url), headers) |> reply
  defcall delete(url)                        , state: state, do: Api.delete(format_url(state, url)) |> reply

  defp format_url(%State{url: url}, path) do
    "#{url}#{path}"
  end
end

