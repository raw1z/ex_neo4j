defmodule ExNeo4j.Node do
  @moduledoc """
  Functions for working with nodes
  """

  defstruct id: nil, properties: %{}, points: %{}

  use Jazz

  alias ExNeo4j.Node
  alias ExNeo4j.PointsParser
  alias ExNeo4j.HttpClient

  @doc """
  creates and return a new node by parsing the response of a create node request
  """
  def new(data) when is_map(data) do
    points = node_points(data)
    properties = node_properties(data)
    id = node_id(points)

    %__MODULE__{
      id: id,
      properties: properties,
      points: points
    }
  end

  @doc """
  replaces all existing properties on the node with the new attributes.
  """
  def update_properties(node, new_properties) when is_map(new_properties) do
    response = HttpClient.put node.points.properties, JSON.encode!(new_properties)
    case response do
      %{status_code: 204} ->
        node = Map.put(node, :properties, new_properties)
        {:ok, node}

      %{status_code: status_code, body: body} ->
        {:error, http_status: status_code, info: body}
    end
  end

  @doc """
  set a property on a given node
  if a property with the given name exists then its value is modified.
  Otherwise a new property is created
  """
  def set_property(%__MODULE__{} = node, name, value) when is_binary(name) do
    response = HttpClient.put(property_point(node, name), JSON.encode!(value))
    case response do
      %{status_code: 204} ->
        new_properties = Map.put(node.properties, binary_to_atom(name), value)
        node = Map.put(node, :properties, new_properties)
        {:ok, node}

      %{status_code: status_code, body: body} ->
        {:error, http_status: status_code, info: body}
    end
  end

  @doc """
  add the given labels to the given node
  """
  def add_labels(%__MODULE__{} = node, labels) when is_list(labels) do
    response = HttpClient.post(labels_point(node), JSON.encode!(labels))
    case response do
      %{status_code: 204} ->
        get_labels(node)
      %{status_code: status_code, body: body} ->
        {:error, http_status: status_code, info: body}
    end
  end

  @doc """
  returns the properties of a given node
  """
  def get_properties(%__MODULE__{} = node) do
    response = HttpClient.get(properties_point(node))
    case response do
      %{status_code: 200, body: body} ->
        {:ok, body}
      %{status_code: status_code, body: body} ->
        {:error, http_status: status_code, info: body}
    end
  end

  @doc """
  returns the labels of a given node
  """
  def get_labels(%__MODULE__{} = node) do
    response = HttpClient.get(labels_point(node))
    case response do
      %{status_code: 200, body: body} ->
        {:ok, body}
      %{status_code: status_code, body: body} ->
        {:error, http_status: status_code, info: body}
    end
  end

  @doc """
  returns the node matching the given label or nil if not found
  """
  def find(id) do
    response = HttpClient.get(url_from_id(id))
    case response do
      %{status_code: 200, body: body} ->
        {:ok, Node.new(body)}
      %{status_code: 404, body: %{"exception" => "NodeNotFoundException"}} ->
        {:ok, nil}
      %{status_code: status_code, body: body} ->
        {:error, http_status: status_code, info: body}
    end
  end

  @doc """
  deletes the given node
  """
  def delete(id) do
    response = HttpClient.delete(url_from_id(id))
    case response do
      %{status_code: 204} ->
        :ok
      %{status_code: status_code, body: body} ->
        {:error, http_status: status_code, info: body}
    end
  end

  defp properties_point(node) do
    node.points.properties
  end

  defp property_point(node, property_name) do
    String.replace(node.points.property, "{key}", property_name)
  end

  defp labels_point(node) do
    node.points.labels
  end

  defp node_id(points) do
    id_from_url(points.self)
  end

  defp node_properties(data) when is_map(data) do
    data["data"]
      |> Map.to_list
      |> Enum.map(fn {key, value} -> {binary_to_atom(key), value} end)
      |> Enum.into(Map.new)
  end

  defp node_points(data) when is_map(data) do
    PointsParser.parse(data, HttpClient.base_url)
  end

  defp id_from_url(node_url) do
    reversed_url = String.reverse(node_url)
    [_, match] = Regex.run(~r/^(\d+)\/.*/, reversed_url)
    {id, _} = Integer.parse String.reverse(match)
    id
  end

  defp url_from_id(id) do
    "/db/data/node/#{id}"
  end
end
