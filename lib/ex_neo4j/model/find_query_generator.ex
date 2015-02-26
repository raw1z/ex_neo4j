defmodule ExNeo4j.Model.FindQueryGenerator do
  def query_with_id(module, id) do
    relationships = model_relationships(module)
    if Enum.empty?(relationships) do
      query_with_id_without_relationships(id)
    else
      query_with_id_and_relationships(id, relationships)
    end
  end
    
  def query_with_properties(module, properties) do
    relationships = model_relationships(module)
    if Enum.empty?(relationships) do
      query_with_properties_without_relationships(module, properties)
    else
      query_with_properties_and_relationships(module, properties, relationships)
    end
  end

  defp model_relationships(module) do
    module.metadata.relationships
  end

  def query_with_properties_without_relationships(module, properties) do
    query_params = properties
                    |> Enum.map(fn {k,v} -> "#{k}: #{inspect(v)}" end)
                    |> Enum.join(", ")

    """
    MATCH (n:#{module.label} {#{query_params}})
    RETURN id(n), n
    """
  end

  def query_with_properties_and_relationships(module, properties, relationships) do
    match_clauses = relationships
                    |> Enum.map(&("OPTIONAL MATCH (n)-[:#{&1.name}]->(#{normalize(&1.name)})"))
                    |> Enum.join("\n")

    return_clauses = relationships
                      |> Enum.map(&(["id(#{normalize(&1.name)})", normalize(&1.name)]))
                      |> List.flatten
                      |> Enum.join(", ")

    query_params = properties
                    |> Enum.map(fn {k,v} -> "#{k}: #{inspect(v)}" end)
                    |> Enum.join(", ")

    """
    MATCH (n:#{module.label} {#{query_params}})
    #{match_clauses}
    RETURN id(n), n, #{return_clauses}
    """
  end

  def query_with_id_without_relationships(id) do
    """
    START n=node(#{id})
    RETURN id(n), n
    """
  end

  def query_with_id_and_relationships(id, relationships) do
    match_clauses = relationships
                    |> Enum.map(&("OPTIONAL MATCH (n)-[:#{&1.name}]->(#{normalize(&1.name)})"))
                    |> Enum.join("\n")

    return_clauses = relationships
                      |> Enum.map(&(["id(#{normalize(&1.name)})", normalize(&1.name)]))
                      |> List.flatten
                      |> Enum.join(", ")

    """
    START n=node(#{id})
    #{match_clauses}
    RETURN id(n), n, #{return_clauses}
    """
    
  end

  defp normalize(relationship_name) do
    relationship_name |> Atom.to_string |> String.downcase |> String.to_atom
  end
end
