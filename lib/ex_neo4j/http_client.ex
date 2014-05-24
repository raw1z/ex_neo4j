defmodule ExNeo4j.HttpClient.State do
  defstruct host: "localhost", port: 7474, ssl: false
end

defmodule ExNeo4j.HttpClient.Api do
  use HTTPotion.Base
  use Jazz

  def process_request_headers(headers) do
    [{"X-Stream", "true"}|[{"Accept", "application/json; charset=UTF-8"}|[{"Content-Type", "application/json"}|headers]]]
  end

  def process_response_body(body) do
    body |> iodata_to_binary |> parse_json_body
  end

  defp parse_json_body(""), do: nil
  defp parse_json_body(body), do: JSON.decode!(body)
end

defmodule ExNeo4j.HttpClient do
  use ExActor.GenServer, export: :neo4j_http_client

  alias ExNeo4j.HttpClient.State
  alias ExNeo4j.HttpClient.Api

  definit [ host: host, port: port, ssl: ssl ], do: %State{host: host, port: port, ssl: ssl} |> initial_state
  definit do: %State{} |> initial_state

  defcall base_url, state: state, do: format_url(state, "") |> reply

  defcall host, state: state, do: state.host |> reply
  defcall port, state: state, do: state.port |> reply
  defcall ssl,  state: state, do: state.ssl  |> reply

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

  defp format_url(%State{host: host, port: port, ssl: false}, url) do
    "http://#{host}:#{port}#{url}"
  end

  defp format_url(%State{host: host, port: port, ssl: true}, url) do
    "https://#{host}:#{port}#{url}"
  end
end

