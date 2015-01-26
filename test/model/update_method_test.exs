defmodule Model.UpdateMethodTest do
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
    field :gender

    relationship :FRIEND_OF, Person
    relationship :MARRIED_TO, Person
  end

  test "updates the attributes of a model" do
    person = Person.build(name: "John DOE", age: 20, gender: "female")
    person = Person.update_attributes(person, age: 30, gender: "male")
    assert person.age == 30
    assert person.gender == "male"
  end

  test "updates one attribute of a model" do
    person = Person.build(name: "John DOE", age: 20, gender: "female")
    person = Person.update_attribute(person, :age, 30)
    assert person.age == 30
  end

  test "updates and save a model" do
    fake_successfull_save_existing

    person = Person.build(id: 81776, name: "John DOE", age: 18)
    {:ok, person} = Person.update(person, age: 30)

    assert person.id == 81776
    assert person.name == "John DOE"
    assert person.age == 30
    assert person.created_at == "2014-10-14 02:55:03 +0000"
    assert person.updated_at == "2014-10-14 02:55:03 +0000"
  end

  defp fake_successfull_save_existing do
    query = """
    START n=node(81776)
    SET n.age = 30, n.name = "John DOE", n.updated_at = "2014-10-14 02:55:03 +0000"
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
