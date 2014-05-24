defmodule ExNeo4j.ServiceRoot do

  defstruct base_url: nil, version: nil, points: %{}

  use Jazz
  require Lager

  alias ExNeo4j.HttpClient
  alias ExNeo4j.Node
  alias ExNeo4j.PointsParser

  @doc """
  returns the service root
  """
  def get do
    response = HttpClient.get("/db/data/")
    case response do
      %{status_code: 200, body: body} ->
        root = %__MODULE__{
          base_url: HttpClient.base_url,
          version: get_version(body),
          points: list_points(body, HttpClient.base_url)
        }
        {:ok, root}

      %{status_code: status_code, body: body} ->
        {:error, http_status: status_code, info: body}
    end
  end

  @doc """
  returns the version of the neo4j database
  """
  def version(root), do: root.version

  @doc """
  returns the points of the service root
  """
  def points(root), do: root.points

  @doc """
  returns the base url of a service root
  """
  def base_url(root), do: root.base_url

  @doc """
  creates and returns a new node with the given attributes
  """
  def create_node(root, attributes \\ []) when is_list(attributes) do
    data = Enum.into(attributes, %{}) |> JSON.encode!
    response = HttpClient.post node_point(root), data
    case response do
      %{status_code: 201, body: body} ->
        {:ok, Node.new(body)}
      %{status_code: status_code, body: body} ->
        {:error, http_status: status_code, info: body}
    end
  end

  defp node_point(root) do
    root.points.node
  end

  defp list_points(response, base_url) do
    PointsParser.parse(response, base_url)
  end

  defp get_version(response) do
    Map.get(response, "neo4j_version")
  end
end
