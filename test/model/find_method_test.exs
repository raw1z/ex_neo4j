defmodule Model.FindMethodTest do
  use ExUnit.Case
  import Mock

  test "find all with results" do
    enable_mock do
      query = """
      MATCH (n:Test:Person {})
      RETURN id(n), n
      """

      expected_response = [
        %{
          "id(n)" => 81776,
              "n" => %{"name" => "John DOE","email" => "john@doe.fr", "age" => 30, "created_at" => "2014-10-14 02:55:03 +0000", "updated_at" => "2014-10-14 02:55:03 +0000"}
        },
        %{
          "id(n)" => 81777,
              "n" => %{"name" => "Jane DOE","email" => "jane@doe.fr", "age" => 16, "created_at" => "2014-10-14 02:55:03 +0000", "updated_at" => "2014-10-14 02:55:03 +0000"}
        }
      ]

      cypher_returns { :ok, expected_response },
        for_query: query

      {:ok, people} = Person.find()
      assert Enum.count(people) == 2

      person = List.first(people)
      assert person.id == 81776
      assert person.name == "John DOE"
      assert person.email == "john@doe.fr"
      assert person.age == 30
      assert person.created_at == "2014-10-14 02:55:03 +0000"
      assert person.updated_at == "2014-10-14 02:55:03 +0000"
    end
  end

  test "find all without results" do
    enable_mock do
      query = """
      MATCH (n:Test:Person {})
      RETURN id(n), n
      """

      cypher_returns { :ok, [] },
        for_query: query


      {:ok, people} = Person.find()
      assert Enum.count(people) == 0
    end
  end

  test "find all with error" do
    enable_mock do
      query = """
      MATCH (n:Test:Person {})
      RETURN id(n), n
      """

      expected_response = [
        %{
          code: "Neo.ClientError.Statement.InvalidSyntax",
          message: "Invalid input 'T': expected <init> (line 1, column 1)\n\"This is not a valid Cypher Statement.\"\n ^"
        }
      ]

      cypher_returns { :error, expected_response },
        for_query: query

      {:nok, [resp]} = Person.find()
      assert resp.code == "Neo.ClientError.Statement.InvalidSyntax"
      assert resp.message == "Invalid input 'T': expected <init> (line 1, column 1)\n\"This is not a valid Cypher Statement.\"\n ^"
    end
  end

  test "find by id with result" do
    enable_mock do
      query = """
      START n=node(81776)
      RETURN id(n), n
      """

      expected_response = [
        %{
          "id(n)" => 81776,
              "n" => %{"name" => "John DOE","email" => "john@doe.fr", "age" => 30, "created_at" => "2014-10-14 02:55:03 +0000", "updated_at" => "2014-10-14 02:55:03 +0000"}
        }
      ]

      cypher_returns { :ok, expected_response },
        for_query: query

      {:ok, person} = Person.find(81776)
      assert person.id == 81776
      assert person.name == "John DOE"
      assert person.email == "john@doe.fr"
      assert person.age == 30
      assert person.created_at == "2014-10-14 02:55:03 +0000"
      assert person.updated_at == "2014-10-14 02:55:03 +0000"
    end
  end

  test "find by id without result" do
    enable_mock do
      query = """
      START n=node(81776)
      RETURN id(n), n
      """

      expected_response = [
        %{
          code: "Neo.ClientError.Statement.EntityNotFound",
          message: "Node with id 81776"
        }
      ]

      cypher_returns { :error, expected_response },
        for_query: query

      {:ok, person} = Person.find(81776)
      assert person == nil
    end
  end

  test "find by properties" do
    enable_mock do
      query = """
      MATCH (n:Test:Person {age: 30})
      RETURN id(n), n
      """

      expected_response = [
        %{
          "id(n)" => 81776,
              "n" => %{"name" => "John DOE","email" => "john@doe.fr", "age" => 30, "created_at" => "2014-10-14 02:55:03 +0000", "updated_at" => "2014-10-14 02:55:03 +0000"}
        },
        %{
          "id(n)" => 81777,
              "n" => %{"name" => "Jane DOE","email" => "jane@doe.fr", "age" => 30, "created_at" => "2014-10-14 02:55:03 +0000", "updated_at" => "2014-10-14 02:55:03 +0000"}
        }
      ]

      cypher_returns { :ok, expected_response },
        for_query: query

      {:ok, people} = Person.find(age: 30)
      assert Enum.count(people) == 2

      person = List.first(people)
      assert person.id == 81776
      assert person.name == "John DOE"
      assert person.email == "john@doe.fr"
      assert person.age == 30
      assert person.created_at == "2014-10-14 02:55:03 +0000"
      assert person.updated_at == "2014-10-14 02:55:03 +0000"
    end
  end

  test "find by properties without results" do
    enable_mock do
      query = """
      MATCH (n:Test:Person {age: 30})
      RETURN id(n), n
      """

      cypher_returns { :ok, [] },
        for_query: query

      {:ok, people} = Person.find(age: 30)
      assert Enum.count(people) == 0
    end
  end

  test "find by properties with error" do
    enable_mock do
      query = """
      MATCH (n:Test:Person {age: 30})
      RETURN id(n), n
      """

      expected_response = [
        %{
          code: "Neo.ClientError.Statement.InvalidSyntax",
          message: "Invalid input 'T': expected <init> (line 1, column 1)\n\"This is not a valid Cypher Statement.\"\n ^"
        }
      ]

      cypher_returns { :error, expected_response },
        for_query: query

      {:nok, [resp]} = Person.find(age: 30)
      assert resp.code == "Neo.ClientError.Statement.InvalidSyntax"
      assert resp.message == "Invalid input 'T': expected <init> (line 1, column 1)\n\"This is not a valid Cypher Statement.\"\n ^"
    end
  end
end
