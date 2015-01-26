defmodule Model.SaveMethodTest do
  use ExUnit.Case

  setup do
    Mock.fake

    on_exit fn ->
      Mock.unload
    end
  end

  defmodule Person do
    use ExNeo4j.Model
    field :name, required: true
    field :age, type: :integer, required: true

    relationship :FRIEND_OF, Person
    relationship :MARRIED_TO, Person
  end

  test "successfully saves a new model" do
    fake_successfull_save

    person = Person.build(name: "John DOE", age: 20)
    {:ok, person} = Person.save(person)

    assert person.id == 81776
    assert person.name == "John DOE"
    assert person.age == 20
    assert person.created_at == "2014-10-14 02:55:03 +0000"
    assert person.updated_at == "2014-10-14 02:55:03 +0000"
  end

  test "successfully saves an existing model" do
    fake_successfull_save_existing

    person = Person.build(id: 81776, name: "John DOE", age: 18)
    person = Person.update_attributes(person, age: 30)
    {:ok, person} = Person.save(person)

    assert person.id == 81776
    assert person.name == "John DOE"
    assert person.age == 30
    assert person.created_at == "2014-10-14 02:55:03 +0000"
    assert person.updated_at == "2014-10-14 02:55:03 +0000"
  end

  test "parses responses to failed save requests" do
    fake_failed_save

    person = Person.build(name: "John DOE", age: 20)
    {:nok, [resp], person} = Person.save(person)

    assert person.id == nil
    assert resp.code == "Neo.ClientError.Statement.InvalidSyntax"
    assert resp.message == "Invalid input 'T': expected <init> (line 1, column 1)\n\"This is not a valid Cypher Statement.\"\n ^"
  end

  defp fake_failed_save do
    Mock.http_request :post, [ "/db/data/transaction/commit", :_ ], """
    {
      "results" : [ ],
      "errors" : [ {
        "code" : "Neo.ClientError.Statement.InvalidSyntax",
        "message" : "Invalid input 'T': expected <init> (line 1, column 1)\\n\\"This is not a valid Cypher Statement.\\"\\n ^"
      } ]
    }
    """
  end

  defp fake_successfull_save do
    query = """
    CREATE (n:Test:Model:SaveMethodTest:Person { properties })
    RETURN id(n), n
    """

    properties = %{
      properties: %{
        :age => 20,
        :name => "John DOE",
        :validated => true,
        "created_at" => "2014-10-14 02:55:03 +0000",
        "updated_at" => "2014-10-14 02:55:03 +0000"
      }
    }

    params = ExNeo4j.Helpers.format_statements([{query, properties}])
    Mock.http_request :post, [ "/db/data/transaction/commit", params ], """
    {
      "errors": [],
      "results": [
        {
          "columns": ["id(n)", "n"],
          "data": [
            {"row": [81776, {"name":"John DOE", "age":20, "created_at":"2014-10-14 02:55:03 +0000", "updated_at":"2014-10-14 02:55:03 +0000"}]}
          ]
        }
      ]
    }
    """
  end

  defp fake_successfull_save_existing do
    query = """
    START n=node(81776)
    SET n.age = 30, n.name = "John DOE", n.validated = true, n.updated_at = "2014-10-14 02:55:03 +0000"
    """

    params = ExNeo4j.Helpers.format_statements([{query, %{}}])
    Mock.http_request :post, [ "/db/data/transaction/commit", params ], """
    {
      "errors": [],
      "results": [
        {
          "columns": ["id(n)", "n"],
          "data": [
            {"row": [81776, {"name":"John DOE", "age":30, "created_at":"2014-10-14 02:55:03 +0000", "updated_at":"2014-10-14 02:55:03 +0000"}]}
          ]
        }
      ]
    }
    """
  end
end
