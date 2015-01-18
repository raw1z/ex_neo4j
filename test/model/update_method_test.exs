defmodule Model.UpdateMethodTest do
  use ExUnit.Case

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
end
