defmodule Model.FindQueryGeneratorTest do
  use ExUnit.Case
  alias ExNeo4j.Model.FindQueryGenerator

  defmodule ModelWithoutRelationShip do
    use ExNeo4j.Model
    field :name
  end

  test "finds by properties value for model without relationships" do
    query = FindQueryGenerator.query_with_properties ModelWithoutRelationShip, name: "john"
    assert query == """
    MATCH (n:Test:Model:FindQueryGeneratorTest:ModelWithoutRelationShip {name: "john"})
    RETURN id(n), n
    """
  end

  test "finds by properties value for model with relationships" do
    query = FindQueryGenerator.query_with_properties Person, name: "john", age: 30
    assert query == """
    MATCH (n:Test:Person {name: "john", age: 30})
    OPTIONAL MATCH (n)-[:FRIEND_OF]->(friend_of)
    OPTIONAL MATCH (n)-[:MARRIED_TO]->(married_to)
    RETURN id(n), n, id(friend_of), friend_of, id(married_to), married_to
    """
  end

  test "find by id for model without relationships" do
    query = FindQueryGenerator.query_with_id ModelWithoutRelationShip, 1
    assert query == """
    START n=node(1)
    RETURN id(n), n
    """
  end

  test "finds by id for model with relationships" do
    query = FindQueryGenerator.query_with_id Person, 1
    assert query == """
    START n=node(1)
    OPTIONAL MATCH (n)-[:FRIEND_OF]->(friend_of)
    OPTIONAL MATCH (n)-[:MARRIED_TO]->(married_to)
    RETURN id(n), n, id(friend_of), friend_of, id(married_to), married_to
    """
  end
end
