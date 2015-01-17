defmodule PointsParserTest do
  use ExUnit.Case, async: true
  alias ExNeo4j.PointsParser

  @query_result %ExNeo4j.ServiceRoot.ServiceRootQueryResult{
    batch: "http://localhost:7474/db/data/batch",
    constraints: "http://localhost:7474/db/data/schema/constraint",
    cypher: "http://localhost:7474/db/data/cypher",
    extensions: %{},
    extensions_info: "http://localhost:7474/db/data/ext",
    indexes: "http://localhost:7474/db/data/schema/index",
    neo4j_version: "2.1.5",
    node: "http://localhost:7474/db/data/node",
    node_index: "http://localhost:7474/db/data/index/node",
    node_labels: "http://localhost:7474/db/data/labels",
    relationship_index: "http://localhost:7474/db/data/index/relationship",
    relationship_types: "http://localhost:7474/db/data/relationship/types",
    transaction: "http://localhost:7474/db/data/transaction"}

  test "parses the points inside a json response" do
    points = PointsParser.parse(@query_result, "http://localhost:7474")
    assert points.batch == "/db/data/batch"
    assert points.constraints == "/db/data/schema/constraint"
    assert points.cypher == "/db/data/cypher"
    assert points.extensions_info == "/db/data/ext"
    assert points.indexes == "/db/data/schema/index"
    assert points.node == "/db/data/node"
    assert points.node_index == "/db/data/index/node"
    assert points.node_labels == "/db/data/labels"
    assert points.relationship_index == "/db/data/index/relationship"
    assert points.relationship_types == "/db/data/relationship/types"
    assert points.transaction == "/db/data/transaction"
  end

  test "parses the points inside a json response with a base url containing authentication info" do
    points = PointsParser.parse(@query_result, "http://user:password@localhost:7474")
    assert points.batch == "/db/data/batch"
    assert points.constraints == "/db/data/schema/constraint"
    assert points.cypher == "/db/data/cypher"
    assert points.extensions_info == "/db/data/ext"
    assert points.indexes == "/db/data/schema/index"
    assert points.node == "/db/data/node"
    assert points.node_index == "/db/data/index/node"
    assert points.node_labels == "/db/data/labels"
    assert points.relationship_index == "/db/data/index/relationship"
    assert points.relationship_types == "/db/data/relationship/types"
    assert points.transaction == "/db/data/transaction"
  end
end
