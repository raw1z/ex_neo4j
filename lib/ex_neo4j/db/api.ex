# TODO: Decide what to do with this module
defmodule ExNeo4j.Db.Api do
  defmacro __using__(_opts) do
    quote do
      alias ExNeo4j.Node

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
    end
  end
end
