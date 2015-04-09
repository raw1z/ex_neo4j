defmodule ExNeo4j.Model.DeleteMethod do
  def generate(_metadata) do
    quote do
      def delete(%__MODULE__{}=model) do
        query1 = """
        START n=node(#{model.id})
        OPTIONAL MATCH (n)-[r]-()
        DELETE n,r
        """

        query2 = """
        START n=node(#{model.id})
        DELETE n
        """

        case ExNeo4j.Db.cypher([{query1, %{}}, {query2, %{}}]) do
          {:ok, _} -> :ok
          {:error, resp} -> {:nok, resp}
        end
      end

      def delete_all() do
        query1 = """
        OPTIONAL MATCH (n:#{@label})-[r]-()
        DELETE n,r
        """

        query2 = """
        MATCH (n:#{@label}) DELETE n
        """

        case ExNeo4j.Db.cypher([{query1, %{}}, {query2, %{}}]) do
          {:ok, _} -> :ok
          {:error, resp} -> {:nok, resp}
        end
      end
    end
  end
end
