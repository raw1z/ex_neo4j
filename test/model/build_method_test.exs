defmodule Model.BuildMethodTest do
  use ExUnit.Case, async: true

  defmodule Person do
    use ExNeo4j.Model
    field :name, required: true
    field :age, type: :integer
    field :email, required: true, unique: true, format: ~r/\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b/

    relationship :FRIEND_OF, Person
    relationship :MARRIED_TO, Person
  end

  test "defines a method for building models without specifying attributes" do
    person = Person.build
    assert person.name == nil
    assert person.age == nil
    assert person.email == nil
  end

  test "defines a method for building models by specifying required attributes" do
    person = Person.build(name: "John DOE", email: "johndoe@example.com")
    assert person.name == "John DOE"
    assert person.age == nil
    assert person.email == "johndoe@example.com"
  end

  test "defines a method for building models by specifying one attribute at the time" do
    person = Person.build(name: "John DOE")
    assert person.name == "John DOE"
    assert person.age == nil
    assert person.email == nil

    person = Person.build(email: "johndoe@example.com")
    assert person.name == nil
    assert person.age == nil
    assert person.email == "johndoe@example.com"

    person = Person.build(age: 30)
    assert person.name == nil
    assert person.age == 30
    assert person.email == nil
  end
end
