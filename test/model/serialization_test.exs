defmodule Model.SerializationTest do
  use ExUnit.Case

  test "serializes a model" do
    person = Person.build(name: "John DOE", email: "john@doe.fr", age: 30)
    assert Person.to_json(person) == "{\"people\":[{\"updatedAt\":null,\"name\":\"John DOE\",\"marriedTo\":[],\"id\":null,\"friendOf\":[],\"errors\":null,\"email\":\"john@doe.fr\",\"createdAt\":null,\"age\":30}]}"
  end

  test "serializes an array of model" do
    people = [Person.build(id: 1, name: "John DOE"), Person.build(id: 2, name: "Jane DOE")]
    assert Person.to_json(people) == "{\"people\":[{\"updatedAt\":null,\"name\":\"John DOE\",\"marriedTo\":[],\"id\":1,\"friendOf\":[],\"errors\":null,\"email\":null,\"createdAt\":null,\"age\":null},{\"updatedAt\":null,\"name\":\"Jane DOE\",\"marriedTo\":[],\"id\":2,\"friendOf\":[],\"errors\":null,\"email\":null,\"createdAt\":null,\"age\":null}]}"
  end

  test "serializes a model with relationships" do
    john = Person.build(id: 1, name: "John DOE", email: "john@doe.fr", age: 30)
    jane = Person.build(name: "Jane DOE", email: "jane@doe.fr", age: 20, friend_of: [john])
    assert Person.to_json(jane) == "{\"people\":[{\"updatedAt\":null,\"name\":\"Jane DOE\",\"marriedTo\":[],\"id\":null,\"friendOf\":[1],\"errors\":null,\"email\":\"jane@doe.fr\",\"createdAt\":null,\"age\":20},{\"updatedAt\":null,\"name\":\"John DOE\",\"marriedTo\":[],\"id\":1,\"friendOf\":[],\"errors\":null,\"email\":\"john@doe.fr\",\"createdAt\":null,\"age\":30}]}"
  end
end
