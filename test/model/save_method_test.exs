defmodule Model.SaveMethodTest do
  use ExUnit.Case
  import Mock

  test "successfully saves a new model" do
    enable_mock do
      query = """
      CREATE (n:Test:Person { properties })
      RETURN id(n), n
      """

      query_params = %{
        properties: %{
          :age        => 20,
          :email      => "john@doe.fr",
          :name       => "John DOE",
          :created_at => "2014-10-14 02:55:03 +0000",
          :updated_at => "2014-10-14 02:55:03 +0000"
        }
      }

      expected_response = [
        %{
          "id(n)" => 81776,
              "n" => %{"name" => "John DOE","email" => "john@doe.fr", "age" => 20, "created_at" => "2014-10-14 02:55:03 +0000", "updated_at" => "2014-10-14 02:55:03 +0000"}
        }
      ]

      cypher_returns { :ok, expected_response },
        for_query: query,
        with_params: query_params

      person = Person.build(name: "John DOE", email: "john@doe.fr", age: 20)
      {:ok, person} = Person.save(person)

      assert person.id == 81776
      assert person.email == "john@doe.fr"
      assert person.name == "John DOE"
      assert person.age == 20
      assert person.created_at == "2014-10-14 02:55:03 +0000"
      assert person.updated_at == "2014-10-14 02:55:03 +0000"
    end
  end

  test "successfully saves an existing model" do
    enable_mock do
      query = """
      START n=node(81776)
      SET n.age = 30, n.email = "john@doe.fr", n.name = "John DOE", n.updated_at = "2014-10-14 02:55:03 +0000"
      """

      expected_response = [
        %{
          "id(n)" => 81776,
              "n" => %{"name" => "John DOE","email" => "john@doe.fr", "age" => 30, "created_at" => "2014-10-14 02:55:03 +0000", "updated_at" => "2014-10-14 02:55:03 +0000"}
        }
      ]

      cypher_returns { :ok, expected_response },
        for_query: query,
        with_params: %{}

      person = Person.build(id: 81776, name: "John DOE", email: "john@doe.fr", age: 18)
      person = Person.update_attributes(person, age: 30)
      {:ok, person} = Person.save(person)

      assert person.id == 81776
      assert person.name == "John DOE"
      assert person.email == "john@doe.fr"
      assert person.age == 30
      assert person.created_at == "2014-10-14 02:55:03 +0000"
      assert person.updated_at == "2014-10-14 02:55:03 +0000"
    end
  end

  test "parses responses to failed save requests" do
    enable_mock do
      query = """
      START n=node(81776)
      SET n.age = 30, n.email = "john@doe.fr", n.name = "John DOE", n.updated_at = "2014-10-14 02:55:03 +0000"
      """

      expected_response = [
        %{
          code: "Neo.ClientError.Statement.InvalidSyntax",
          message: "Invalid input 'T': expected <init> (line 1, column 1)\n\"This is not a valid Cypher Statement.\"\n ^"
        }
      ]

      cypher_returns { :error, expected_response },
        for_query: query,
        with_params: %{}

      person = Person.build(id: 81776, name: "John DOE", email: "john@doe.fr", age: 18)
      person = Person.update_attributes(person, age: 30)
      {:nok, [resp], _person} = Person.save(person)

      assert resp.code == "Neo.ClientError.Statement.InvalidSyntax"
      assert resp.message == "Invalid input 'T': expected <init> (line 1, column 1)\n\"This is not a valid Cypher Statement.\"\n ^"
    end
  end
end
