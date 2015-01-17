defmodule ExNeo4j.Db.Core do
  defmacro __using__(_opts) do
    quote do
      use ExActor.GenServer, export: :neo4j_db
      alias ExNeo4j.HttpClient
      alias ExNeo4j.ServiceRoot

      defstart start(url \\ nil)
      defstart start_link(url \\ nil) do
        HttpClient.start_link(url)
        {:ok, service_root} = ServiceRoot.get
        service_root |> initial_state
      end

      @doc """
      returns the version of the neo4j database
      """
      defcall version(), state: service_root, do: reply(service_root.version)

      @doc """
      returns the points of the service root
      """
      defcall points(), state: service_root, do: reply(service_root.points)

      @doc """
      returns the base url of a service root
      """
      defcall base_url(), state: service_root, do: reply(service_root.base_url)
    end
  end
end
