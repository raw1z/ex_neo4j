defmodule Model.FindMethodTest do
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

  test "find all with results" do
    Mock.fake_find_all_request """
    {
      "errors": [],
      "results": [
        {
          "columns": ["id(n)", "n"],
          "data": [
            {"row": [81776, {"name":"John DOE", "age":30, "created_at":"2014-10-14 02:55:03 +0000", "updated_at":"2014-10-14 02:55:03 +0000"}]},
            {"row": [81777, {"name":"Jane DOE", "age":16, "created_at":"2014-10-14 02:55:03 +0000", "updated_at":"2014-10-14 02:55:03 +0000"}]}
          ]
        }
      ]
    }
    """

    {:ok, people} = Person.find()
    assert Enum.count(people) == 2

    person = List.first(people)
    assert person.id == 81776
    assert person.name == "John DOE"
    assert person.age == 30
    assert person.created_at == "2014-10-14 02:55:03 +0000"
    assert person.updated_at == "2014-10-14 02:55:03 +0000"
  end

  test "find all without results" do
    Mock.fake_find_all_request """
    {
      "errors": [],
      "results": []
    }
    """

    {:ok, people} = Person.find()
    assert Enum.count(people) == 0
  end

  test "find all with error" do
    Mock.fake_find_all_request """
    {
      "results" : [ ],
      "errors" : [ {
        "code" : "Neo.ClientError.Statement.InvalidSyntax",
        "message" : "Invalid input 'T': expected <init> (line 1, column 1)\\n\\"This is not a valid Cypher Statement.\\"\\n ^"
      } ]
    }
    """

    {:nok, [resp]} = Person.find()
    assert resp.code == "Neo.ClientError.Statement.InvalidSyntax"
    assert resp.message == "Invalid input 'T': expected <init> (line 1, column 1)\n\"This is not a valid Cypher Statement.\"\n ^"
  end

  test "find by id with result" do
    Mock.fake_find_by_id_request 81776, """
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

    {:ok, person} = Person.find(81776)
    assert person.id == 81776
    assert person.name == "John DOE"
    assert person.age == 30
    assert person.created_at == "2014-10-14 02:55:03 +0000"
    assert person.updated_at == "2014-10-14 02:55:03 +0000"
  end

  test "find by id without result" do
    Mock.fake_find_by_id_request 81776, """
    {
      "errors": [
        {
          "code": "Neo.ClientError.Statement.EntityNotFound",
          "message": "Node with id 81776"
        }
      ],
      "results": []
    }
    """

    {:ok, person} = Person.find(81776)
    assert person == nil
  end

  test "find by id with error" do
    Mock.fake_find_by_id_request 81776, """
    {
      "results" : [ ],
      "errors" : [ {
        "code" : "Neo.ClientError.Statement.InvalidSyntax",
        "message" : "Invalid input 'T': expected <init> (line 1, column 1)\\n\\"This is not a valid Cypher Statement.\\"\\n ^"
      } ]
    }
    """

    {:nok, [resp]} = Person.find(81776)
    assert resp.code == "Neo.ClientError.Statement.InvalidSyntax"
    assert resp.message == "Invalid input 'T': expected <init> (line 1, column 1)\n\"This is not a valid Cypher Statement.\"\n ^"
  end

  test "find by properties" do
    Mock.fake_find_by_properties_request """
    {
      "errors": [],
      "results": [
        {
          "columns": ["id(n)", "n"],
          "data": [
            {"row": [81776, {"name":"John DOE", "age":30, "created_at":"2014-10-14 02:55:03 +0000", "updated_at":"2014-10-14 02:55:03 +0000"}]},
            {"row": [81777, {"name":"Jane DOE", "age":30, "created_at":"2014-10-14 02:55:03 +0000", "updated_at":"2014-10-14 02:55:03 +0000"}]}
          ]
        }
      ]
    }
    """

    {:ok, people} = Person.find(age: 30)
    assert Enum.count(people) == 2

    person = List.first(people)
    assert person.id == 81776
    assert person.name == "John DOE"
    assert person.age == 30
    assert person.created_at == "2014-10-14 02:55:03 +0000"
    assert person.updated_at == "2014-10-14 02:55:03 +0000"
  end

  test "find by properties without results" do
    Mock.fake_find_by_properties_request """
    {
      "errors": [],
      "results": []
    }
    """

    {:ok, people} = Person.find(age: 30)
    assert Enum.count(people) == 0
  end

  test "find by properties with error" do
    Mock.fake_find_by_properties_request """
    {
      "results" : [ ],
      "errors" : [ {
        "code" : "Neo.ClientError.Statement.InvalidSyntax",
        "message" : "Invalid input 'T': expected <init> (line 1, column 1)\\n\\"This is not a valid Cypher Statement.\\"\\n ^"
      } ]
    }
    """

    {:nok, [resp]} = Person.find(age: 30)
    assert resp.code == "Neo.ClientError.Statement.InvalidSyntax"
    assert resp.message == "Invalid input 'T': expected <init> (line 1, column 1)\n\"This is not a valid Cypher Statement.\"\n ^"
  end
end
