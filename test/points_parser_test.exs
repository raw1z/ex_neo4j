defmodule PointsParserTest do
  use ExUnit.Case
  use Jazz
  alias ExNeo4j.PointsParser

  test "parses the points inside a json response" do
    data = """
{
  "extensions" : {
  },
  "paged_traverse" : "http://localhost:7474/db/data/node/184/paged/traverse/{returnType}{?pageSize,leaseTime}",
  "labels" : "http://localhost:7474/db/data/node/184/labels",
  "outgoing_relationships" : "http://localhost:7474/db/data/node/184/relationships/out",
  "traverse" : "http://localhost:7474/db/data/node/184/traverse/{returnType}",
  "all_typed_relationships" : "http://localhost:7474/db/data/node/184/relationships/all/{-list|&|types}",
  "property" : "http://localhost:7474/db/data/node/184/properties/{key}",
  "all_relationships" : "http://localhost:7474/db/data/node/184/relationships/all",
  "self" : "http://localhost:7474/db/data/node/184",
  "outgoing_typed_relationships" : "http://localhost:7474/db/data/node/184/relationships/out/{-list|&|types}",
  "properties" : "http://localhost:7474/db/data/node/184/properties",
  "incoming_relationships" : "http://localhost:7474/db/data/node/184/relationships/in",
  "incoming_typed_relationships" : "http://localhost:7474/db/data/node/184/relationships/in/{-list|&|types}",
  "create_relationship" : "http://localhost:7474/db/data/node/184/relationships",
  "data" : {
  }
}
    """
    json = JSON.decode!(data)
    points = PointsParser.parse(json, "http://localhost:7474")

    assert points.paged_traverse == "/db/data/node/184/paged/traverse/{returnType}{?pageSize,leaseTime}"
    assert points.labels == "/db/data/node/184/labels"
    assert points.outgoing_relationships == "/db/data/node/184/relationships/out"
    assert points.traverse == "/db/data/node/184/traverse/{returnType}"
    assert points.all_typed_relationships == "/db/data/node/184/relationships/all/{-list|&|types}"
    assert points.property == "/db/data/node/184/properties/{key}"
    assert points.all_relationships == "/db/data/node/184/relationships/all"
    assert points.self == "/db/data/node/184"
    assert points.outgoing_typed_relationships == "/db/data/node/184/relationships/out/{-list|&|types}"
    assert points.properties == "/db/data/node/184/properties"
    assert points.incoming_relationships == "/db/data/node/184/relationships/in"
    assert points.incoming_typed_relationships == "/db/data/node/184/relationships/in/{-list|&|types}"
    assert points.create_relationship == "/db/data/node/184/relationships"
  end
end
