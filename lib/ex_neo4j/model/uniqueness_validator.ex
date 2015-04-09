defmodule ExNeo4j.Model.UniquenessValidator do
  import ExNeo4j.Model.Validator

  def validate(model, field, module) do
    if model.id == nil do
      field_value = Map.get model, field
      case module.find([{field, field_value}]) do
        {:ok, [_found_model]} ->
          model = add_error model, field, "model.validation.unique"

        _ -> nil
      end
    end

    model
  end
end
