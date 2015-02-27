defmodule Model.SerializationTest do
  use ExUnit.Case

  test "serializes a model" do
    person = Person.build(name: "John DOE", email: "john@doe.fr", age: 30)
    assert Person.to_json(person) == "{\"person\":{\"updatedAt\":null,\"name\":\"John DOE\",\"marriedTo\":[],\"id\":null,\"friendOf\":[],\"errors\":null,\"email\":\"john@doe.fr\",\"createdAt\":null,\"age\":30}}"
  end

  test "serializes an array of model" do
    people = [Person.build(name: "John DOE"), Person.build(name: "Jane DOE")]
    assert Person.to_json(people) == "{\"people\":[{\"updatedAt\":null,\"name\":\"John DOE\",\"marriedTo\":[],\"id\":null,\"friendOf\":[],\"errors\":null,\"email\":null,\"createdAt\":null,\"age\":null},{\"updatedAt\":null,\"name\":\"Jane DOE\",\"marriedTo\":[],\"id\":null,\"friendOf\":[],\"errors\":null,\"email\":null,\"createdAt\":null,\"age\":null}]}"
  end

  test "serializes a model with relationships" do
    john = Person.build(id: 1, name: "John DOE", email: "john@doe.fr", age: 30)
    jane = Person.build(name: "Jane DOE", email: "jane@doe.fr", age: 20, friend_of: [john])
    assert Person.to_json(jane) == "{\"person\":{\"updatedAt\":null,\"name\":\"Jane DOE\",\"marriedTo\":[],\"id\":null,\"friendOf\":[{\"updatedAt\":null,\"name\":\"John DOE\",\"marriedTo\":[],\"id\":1,\"friendOf\":[],\"errors\":null,\"email\":\"john@doe.fr\",\"createdAt\":null,\"age\":30}],\"errors\":null,\"email\":\"jane@doe.fr\",\"createdAt\":null,\"age\":20}}"
  end
end
