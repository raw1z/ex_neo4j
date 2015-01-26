defmodule Model.SerializationTest do
  use ExUnit.Case
  alias Poison, as: JSON

  defmodule Person do
    use ExNeo4j.Model
    field :name, required: true
    field :age, type: :integer
  end

  test "serializes a model" do
    person = Person.build(name: "John DOE", age: 30)
    result = Person.to_json(person) |> JSON.decode!
    assert result["person"]["name"] == "John DOE"
    assert result["person"]["age"] == 30
  end

  test "serializes an array of model" do
    people = [Person.build(name: "John DOE"), Person.build(name: "Jane DOE")]
    result = Person.to_json(people) |> JSON.decode!
    assert Enum.count(result["people"]) == 2

    data = List.first(result["people"])
    assert data["name"] == "John DOE"
  end
end
