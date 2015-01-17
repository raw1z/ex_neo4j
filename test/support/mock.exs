defmodule Mock do
  use ExActor.GenServer, export: :mock
  alias ExNeo4j.HttpClient

  definit do
    :meck.new(HttpClient)
    :meck.expect(HttpClient, :start_link, fn (nil) -> :ok end)
    :meck.expect(HttpClient, :base_url, fn -> "http://localhost:7474" end)
    initial_state(nil)
  end

  defcall http_request(method, params, expected_response), state: state do
    response = %Axe.Response{
      body: expected_response,
      data: nil,
      resp_headers: %{"Access-Control-Allow-Origin" => "*", "Content-Type" => "application/json; charset=UTF-8; stream=true", "Server" => "Jetty(9.0.5.v20130815)", "Transfer-Encoding" => "chunked"},
      status_code: 200,
      url: List.first(params)}

    :meck.expect(HttpClient, method, params, response)

    {:reply, :ok, state}
  end
end
