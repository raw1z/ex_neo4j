defmodule Model.RelationshipTest do
  use ExUnit.Case, async: true

  defmodule Person do
    use ExNeo4j.Model
    field :name
    field :age, type: :integer
    field :email, required: true, unique: true, format: ~r/\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b/

    relationship :FRIEND_OF, Person
    relationship :MARRIED_TO, Person
  end

  test "defines relationships" do
    relationship_names = Person.metadata.relationships |> Enum.map(&(&1.name))
    relationship_related_models = Person.metadata.relationships |> Enum.map(&(&1.related_model))
    assert relationship_names == [:FRIEND_OF, :MARRIED_TO]
    assert relationship_related_models == [Person, Person]
  end

  test "creates fields for each defined relationship" do
    assert Enum.find(Person.metadata.fields, &(&1.name == :friend_of))
    assert Enum.find(Person.metadata.fields, &(&1.name == :married_to))
  end

  test "defines valid attributes for the relationship fiels" do
    field = Enum.find(Person.metadata.fields, &(&1.name == :friend_of))
    assert field.required == false
    assert field.unique == false
    assert field.default == nil
    assert field.transient == false
    assert field.type == :integer
    assert field.format == nil
    assert field.relationship == true
  end
end
