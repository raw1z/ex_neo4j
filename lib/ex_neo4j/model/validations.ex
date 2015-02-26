defmodule ExNeo4j.Model.Validations do
  def generate(metadata) do
    quote do
      defp validate(%__MODULE__{}=model) do
        if model.enable_validations == true do
          unquote generate_for_required_fiels(metadata.fields)
          unquote generate_for_unique_fields(metadata.fields)
          unquote generate_for_formatted_fields(metadata.fields)
          unquote generate_for_user_defined(metadata.validation_functions)
        end

        Map.put(model, :validated, true)
      end
    end
  end

  def generate_for_required_fiels(fields) do
    required_fields = fields
                      |> Enum.filter(fn field -> field.required == true end)
                      |> Enum.map(fn field -> field.name end)

    quote do
      model = Enum.reduce unquote(required_fields), model, fn (field , model) ->
        ExNeo4j.Model.PresenceValidator.validate(model, field)
      end
    end
  end

  defp generate_for_unique_fields(fields) do
    unique_fields = fields
                    |> Enum.filter(fn field -> field.unique == true end)
                    |> Enum.map(fn field -> field.name end)

    quote do
      model = Enum.reduce unquote(unique_fields), model, fn (field, model) ->
        ExNeo4j.Model.UniquenessValidator.validate(model, field, __MODULE__)
      end
    end
  end

  defp generate_for_formatted_fields(fields) do
    formatted_fields = fields
                        |> Enum.filter(fn field -> field.format != nil end)
                        |> Enum.map(fn field -> {field.name, field.format} end)

    quote bind_quoted: [formatted_fields: Macro.escape(formatted_fields)] do
      model = Enum.reduce formatted_fields, model, fn ({field, format}, model) ->
        ExNeo4j.Model.FormatValidator.validate(model, field, format)
      end
    end
  end

  defp generate_for_user_defined(functions) do
    quote do
      model = Enum.reduce unquote(functions), model, fn (func, model) ->
        ExNeo4j.Model.FunctionBasedValidator.validate(model, __MODULE__, func)
      end
    end
  end
end
