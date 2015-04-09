defmodule ExNeo4j.Db do
  use ExNeo4j.Db.Cypher

  @doc """
  returns the version of the neo4j database
  """
  def version(), do: ExNeo4j.ServiceRoot.neo4j_version
end
