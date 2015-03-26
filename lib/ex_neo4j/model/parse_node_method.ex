defmodule ExNeo4j.Model.ParseNodeMethod do
  def generate(_metadata) do
    quote do
      def parse_node(node_data) do
        ExNeo4j.Model.NodeParser.parse(__MODULE__, node_data)
      end
    end
  end
end
