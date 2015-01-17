defmodule ServiceRootTest do
  use ExUnit.Case
  alias ExNeo4j.ServiceRoot

  setup do
    Mock.fake

    on_exit fn ->
      Mock.unload
    end
  end

  test "get the service root" do
    {:ok, root} = ServiceRoot.get
    assert root.base_url == "http://localhost:7474"
    assert root.version == "2.1.5"
    assert root.points.node == "/db/data/node"
    assert root.points.node_index == "/db/data/index/node"
    assert root.points.relationship_index == "/db/data/index/relationship"
    assert root.points.extensions_info == "/db/data/ext"
    assert root.points.relationship_types == "/db/data/relationship/types"
    assert root.points.batch == "/db/data/batch"
    assert root.points.cypher == "/db/data/cypher"
    assert root.points.indexes == "/db/data/schema/index"
    assert root.points.constraints == "/db/data/schema/constraint"
    assert root.points.transaction == "/db/data/transaction"
    assert root.points.node_labels == "/db/data/labels"
  end
end
