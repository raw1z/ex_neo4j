defmodule ExNeo4j.Model.FunctionBasedValidator do
  import ExNeo4j.Model.Validator

  def validate(model, module, func) when is_atom(func) do
    {function_result, _} = Code.eval_string "#{func}(model)", [model: model], [delegate_locals_to: module]
    case function_result do
      {field, message} when is_atom(field) and is_binary(message) ->
        model = add_error model, field, message

      _ -> nil
    end

    model
  end
end
