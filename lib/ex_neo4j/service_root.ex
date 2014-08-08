defmodule ExNeo4j.ServiceRoot do

  defstruct base_url: nil, version: nil, points: %{}

  use Jazz

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

  @doc """
  returns the node tagged with the given label
  """
  def nodes_with_label(root, label) when is_binary(label) do
    response = HttpClient.get labelled_nodes_point(root, label)
    case response do
      %{status_code: 200, body: body} ->
        {:ok, Enum.map(body, fn data -> Node.new(data) end)}
      %{status_code: status_code, body: body} ->
        {:error, http_status: status_code, info: body}
    end
  end

  @doc """
  run a cypher query and returns the result
  """
  def cypher(root, query), do: cypher(root, query, %{})
  def cypher(root, query, params) when is_list(params), do: cypher(root, query, Enum.into(params, %{}))
  def cypher(root, query, params) when is_map(params) do
    data = JSON.encode! %{ query: query, params: params }
    response = HttpClient.post cypher_point(root), data
    case response do
      %{status_code: 200, body: body} ->
        {:ok, format_cypher_response(body)}
      %{status_code: status_code, body: body} ->
        {:error, http_status: status_code, info: body}
    end
  end

  defp format_cypher_response(response) do
    columns = response["columns"]
    response["data"]
    |> Enum.map(fn data -> Enum.zip(columns, data) end)
    |> Enum.map(fn data -> Enum.into(data, %{}) end)
  end

  defp cypher_point(root) do
    root.points.cypher
  end

  defp labelled_nodes_point(root, label) do
    String.replace(root.points.labelled_nodes, "{label}", label)
  end

  defp node_point(root) do
    root.points.node
  end

  defp list_points(response, base_url) do
    points = PointsParser.parse(response, base_url)
    Map.put points,
      :labelled_nodes, "/db/data/label/{label}/nodes"
  end

  defp get_version(response) do
    Map.get(response, "neo4j_version")
  end
end
