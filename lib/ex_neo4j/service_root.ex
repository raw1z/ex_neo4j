defmodule ExNeo4j.ServiceRoot do

  defstruct base_url: nil, version: nil, points: %{}

  alias ExNeo4j.HttpClient
  alias ExNeo4j.PointsParser

  defmodule ServiceRootQueryResult do
    defstruct extensions: {},
              node: nil,
              node_index: nil,
              relationship_index: nil,
              extensions_info: nil,
              relationship_types: nil,
              batch: nil,
              cypher: nil,
              indexes: nil,
              constraints: nil,
              transaction: nil,
              node_labels: nil,
              neo4j_version: nil
  end

  @doc """
  returns the service root
  """
  def get do
    response = HttpClient.get("/db/data/")
    case response do
      %{status_code: 200, body: body} ->
        result = Poison.decode!(response.body, as: ServiceRootQueryResult)
        root = %__MODULE__{
          base_url: HttpClient.base_url,
          version: get_version(result),
          points: list_points(result, HttpClient.base_url)
        }
        {:ok, root}

      %{status_code: status_code, body: body} ->
        {:error, http_status: status_code, info: body}
    end
  end

  def cypher_point(root) do
    root.points.cypher
  end

  def labelled_nodes_point(root, label) do
    String.replace(root.points.labelled_nodes, "{label}", label)
  end

  def node_point(root) do
    root.points.node
  end

  defp list_points(result, base_url) do
    points = PointsParser.parse(result, base_url)
    Map.put points,
      :labelled_nodes, "/db/data/label/{label}/nodes"
  end

  defp get_version(result) do
    result.neo4j_version
  end
end
