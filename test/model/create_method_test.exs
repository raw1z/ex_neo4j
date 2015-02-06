defmodule Model.CreateMethodTest do
  use ExUnit.Case

  setup do
    Mock.fake

    on_exit fn ->
      Mock.unload
    end
  end

  test "parses responses to successfull save requests" do
    fake_successfull_save

    {:ok, person} = Person.create(name: "John DOE", email: "john@doe.fr")

    assert person.id == 81776
    assert person.name == "John DOE"
    assert person.email == "john@doe.fr"
    assert person.created_at == "2014-10-14 02:55:03 +0000"
    assert person.updated_at == "2014-10-14 02:55:03 +0000"
  end

  test "parses responses to failed save requests" do
    fake_failed_save

    {:nok, [resp], person} = Person.create(name: "John DOE", email: "john@doe.fr")

    assert person.id == nil
    assert resp.code == "Neo.ClientError.Statement.InvalidSyntax"
    assert resp.message == "Invalid input 'T': expected <init> (line 1, column 1)\n\"This is not a valid Cypher Statement.\"\n ^"
  end

  defp fake_failed_save do
    Mock.http_request :post, [ "/db/data/transaction/commit", :_ ], """
    {
      "results" : [ ],
      "errors" : [ {
        "code" : "Neo.ClientError.Statement.InvalidSyntax",
        "message" : "Invalid input 'T': expected <init> (line 1, column 1)\\n\\"This is not a valid Cypher Statement.\\"\\n ^"
      } ]
    }
    """
  end

  defp fake_successfull_save do
    Mock.http_request :post, [ "/db/data/transaction/commit", :_ ], """
    {
      "errors": [],
      "results": [
        {
          "columns": ["id(n)", "n"],
          "data": [
            {"row": [81776, {"name":"John DOE", "email":"john@doe.fr", "created_at":"2014-10-14 02:55:03 +0000", "updated_at":"2014-10-14 02:55:03 +0000"}]}
          ]
        }
      ]
    }
    """
  end
end
