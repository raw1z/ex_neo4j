defmodule Model.SaveMethodCallbacksTest do
  use ExUnit.Case
  import Mock

  setup_all do
    Agent.start_link(fn -> [] end, name: :buffer)
    :ok
  end

  setup do
    Agent.update :buffer, fn _x -> [] end
    :ok
  end

  defmodule CallbackTester do
    use ExNeo4j.Model

    field :buffer, transient: true, default: "$"

    before_save   :log_before_save
    before_update :log_before_update
    before_create :log_before_create
    after_save    :log_after_save
    after_update  :log_after_update
    after_create  :log_after_create
    after_find    :log_after_find

    def log_before_save(model) do
      Agent.update(:buffer, &([:before_save|&1]))
      model
    end

    def log_before_create(model) do
      Agent.update(:buffer, &([:before_create|&1]))
      model
    end

    def log_before_update(model) do
      Agent.update(:buffer, &([:before_update|&1]))
      model
    end

    def log_after_save(model) do
      Agent.update(:buffer, &([:after_save|&1]))
      model
    end

    def log_after_create(model) do
      Agent.update(:buffer, &([:after_create|&1]))
      model
    end

    def log_after_update(model) do
      Agent.update(:buffer, &([:after_update|&1]))
      model
    end

    def log_after_find(model) do
      Agent.update(:buffer, &([:after_find|&1]))
      model
    end
  end

  test "calls the callbacks in the right order for created models" do
    enable_mock do
      query = """
      CREATE (n:Test:Model.SaveMethodCallbacksTest:CallbackTester { })
      RETURN id(n), n
      """

      expected_response = [
        %{
          "id(n)" => 81776,
              "n" => %{}
        }
      ]

      cypher_returns { :ok, expected_response },
        for_query: query,
        with_params: %{}

      {:ok, _tester} = CallbackTester.create()
      assert Agent.get(:buffer, &(&1)) == [:after_create, :after_save, :before_create, :before_save]
    end
  end

  test "calls the callbacks in the right order for udpated models" do
    enable_mock do
      query = """
      START n=node(81776)
      SET n.updated_at = "2014-10-14 02:55:03 +0000"
      """

      expected_response = [
        %{
          "id(n)" => 81776,
              "n" => %{}
        }
      ]

      cypher_returns { :ok, expected_response },
        for_query: query,
        with_params: %{}

      tester = CallbackTester.build(id: 81776)
      {:ok, _tester} = CallbackTester.update(tester, [])
      assert Agent.get(:buffer, &(&1)) == [:after_update, :after_save, :before_update, :before_save]
    end
  end

  test "Do not call the after callbacks for failed saves" do
    enable_mock do
      query = """
      CREATE (n:Test:Model.SaveMethodCallbacksTest:CallbackTester { })
      RETURN id(n), n
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

      {:nok, _resp, _tester} = CallbackTester.create()
      assert Agent.get(:buffer, &(&1)) == [:before_create, :before_save]
    end
  end

  test "Do not call the after callbacks for failed updates" do
    enable_mock do
      query = """
      START n=node(81776)
      SET n.updated_at = "2014-10-14 02:55:03 +0000"
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

      tester = CallbackTester.build(id: 81776)
      {:nok, _resp, _tester} = CallbackTester.update(tester, [])
      assert Agent.get(:buffer, &(&1)) == [:before_update, :before_save]
    end
  end

  test "calls the after_find callbacks for find with many results" do
    enable_mock do
      query = """
      MATCH (n:Test:Model.SaveMethodCallbacksTest:CallbackTester {})
      RETURN id(n), n
      """

      expected_response = [
        %{
          "id(n)" => 81776,
              "n" => %{}
        },
        %{
          "id(n)" => 81777,
              "n" => %{}
        }
      ]

      cypher_returns { :ok, expected_response },
        for_query: query

      {:ok, _testers} = CallbackTester.find()
      assert Agent.get(:buffer, &(&1)) == [:after_find, :after_find]
    end
  end

  test "calls the after_find callbacks for find by id" do
    enable_mock do
      query = """
      START n=node(81776)
      RETURN id(n), n
      """

      expected_response = [
        %{
          "id(n)" => 81776,
              "n" => %{}
        }
      ]

      cypher_returns { :ok, expected_response },
        for_query: query

      {:ok, _tester} = CallbackTester.find(81776)
      assert Agent.get(:buffer, &(&1)) == [:after_find]
    end
  end

  test "do not call the after_find callbacks for failed find requests" do
    enable_mock do
      query = """
      MATCH (n:Test:Model.SaveMethodCallbacksTest:CallbackTester {})
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

      {:nok, _} = CallbackTester.find()
      assert Agent.get(:buffer, &(&1)) == []
    end
  end
end

