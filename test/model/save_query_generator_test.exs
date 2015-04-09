defmodule Model.SaveQueryGeneratorTest do
  use ExUnit.Case
  import Mock
  alias ExNeo4j.Model.SaveQueryGenerator

  test "generates valid query for updated model" do
    enable_mock do
      john = Person.build(id: 81776, name: "John Doe", email: "john@doe.fr", age: 30)
      {query, query_params} = SaveQueryGenerator.query_for_model(john, Person)
      assert query == """
      START n=node(81776)
      SET n.age = 30, n.email = "john@doe.fr", n.name = "John Doe", n.updated_at = "2014-10-14 02:55:03 +0000"
      """
      assert query_params == %{}
    end
  end

  test "generates valid query for new model without relationships" do
    enable_mock do
      john = Person.build(name: "John Doe", email: "john@doe.fr", age: 30)
      {query, query_params} = SaveQueryGenerator.query_for_model(john, Person)
      assert query == """
      CREATE (n:Test:Person { properties })
      RETURN id(n), n
      """
      assert query_params == %{
        properties: %{
          age: 30, created_at: "2014-10-14 02:55:03 +0000",
          email: "john@doe.fr", name: "John Doe",
          updated_at: "2014-10-14 02:55:03 +0000"}}
    end
  end

  test "generates valid query for new model with relationships" do
    enable_mock do
      john = Person.build(name: "John Doe", email: "john@doe.fr", age: 30, friend_of: [1,2], married_to: 3)
      {query, query_params} = SaveQueryGenerator.query_for_model(john, Person)
      assert query == """
      START friend_of_1=node(1), friend_of_2=node(2), married_to_3=node(3)
      CREATE (n:Test:Person { properties })
      CREATE (n)-[:FRIEND_OF]->(friend_of_1)
      CREATE (n)-[:FRIEND_OF]->(friend_of_2)
      CREATE (n)-[:MARRIED_TO]->(married_to_3)
      RETURN id(n), n, id(friend_of_1), friend_of_1, id(friend_of_2), friend_of_2, id(married_to_3), married_to_3
      """
      assert query_params == %{
        properties: %{
          age: 30, created_at: "2014-10-14 02:55:03 +0000",
          email: "john@doe.fr", name: "John Doe",
          updated_at: "2014-10-14 02:55:03 +0000"}}
    end
  end
end
