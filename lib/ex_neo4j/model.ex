defmodule ExNeo4j.Model do @doc false
  @moduledoc """
  Base class for ExNeo4j models
  """

  defmacro __using__(_opts) do
    quote do
      import Kernel, except: [def: 1, def: 2, defp: 1, defp: 2]
      import ExNeo4j.Model

      Module.register_attribute(__MODULE__ , :fields               , accumulate: true)
      Module.register_attribute(__MODULE__ , :relationships        , accumulate: true)
      Module.register_attribute(__MODULE__ , :functions            , accumulate: true)
      Module.register_attribute(__MODULE__ , :callbacks            , accumulate: true)
      Module.register_attribute(__MODULE__ , :validation_functions , accumulate: true)

      @label "#{Mix.env |> Atom.to_string |> String.capitalize}:#{String.replace(Macro.to_string(__MODULE__), ".", ":")}"
      @before_compile ExNeo4j.Model

      field :id, type: :integer
      field :errors, transient: true
      field :created_at, type: :date
      field :updated_at, type: :date
      field :validated, type: :boolean, default: false, transient: true
      field :enable_validations, type: :boolean, default: true, transient: true
    end
  end

  @doc false
  defmacro __before_compile__(env) do
    metadata = ExNeo4j.Model.Metadata.new(env.module)

    quote do
      unquote ExNeo4j.Model.Struct.generate(metadata)
      unquote ExNeo4j.Model.BuildMethod.generate(metadata)
      unquote ExNeo4j.Model.SaveMethod.generate(metadata)
      unquote ExNeo4j.Model.CreateMethod.generate(metadata)
      unquote ExNeo4j.Model.UpdateMethod.generate(metadata)
      unquote ExNeo4j.Model.FindMethod.generate(metadata)
      unquote ExNeo4j.Model.DeleteMethod.generate(metadata)
      unquote ExNeo4j.Model.Serialization.generate(metadata)
      unquote ExNeo4j.Model.Validations.generate(metadata)

      @doc """
      returns the label of the model
      """
      def label do
        @label
      end

      @doc """
      returns the metadata for the model
      """
      def metadata do
        unquote Macro.escape(metadata)
      end

      unquote generate_functions(metadata.functions)
    end
  end

  defp generate_functions(functions) do
    Enum.map functions, fn
      {:public, call, expr} ->
        quote do
          Kernel.def unquote(call), unquote(expr)
        end
      {:private, call, expr} ->
        quote do
          Kernel.defp unquote(call), unquote(expr)
        end
    end
  end

  defmacro def(call, expr \\ nil) do
    call = Macro.escape(call)
    expr = Macro.escape(expr)
    quote do
      @functions {:public, unquote(call), unquote(expr)}
    end
  end

  defmacro defp(call, expr \\ nil) do
    call = Macro.escape(call)
    expr = Macro.escape(expr)
    quote do
      @functions {:private, unquote(call), unquote(expr)}
    end
  end

  @doc """
  Defines a field for the model

  ## Example

      defmodule User do
        use ExNeo4j.Model

        field :name
        field :email
      end
  """
  defmacro field(name, attributes \\ []) do
    quote do
      @fields {unquote(name), unquote(attributes)}
    end
  end

  @doc """
  Defines a relationship for the model

  ## Example

      defmodule User do
        use ExNeo4j.Model

        field :name
        field :email
        relationship :FRIEND_OF, User
      end
  """
  defmacro relationship(name, related_model) do
    field_name = name |> Atom.to_string |> String.downcase |> String.to_atom
    field_attributes = [relationship: true, type: :integer]
    quote do
      @fields {unquote(field_name), unquote(field_attributes)}
      @relationships {unquote(name), unquote(related_model)}
    end
  end

  defmacro validate_with(method_name) when is_atom(method_name) do
    quote do
      @validation_functions unquote(method_name)
    end
  end

  @doc """
  declare a before_save callback
  """
  defmacro before_save(method_name) when is_atom(method_name) do
    quote do
      @callbacks {:before_save, unquote(method_name)}
    end
  end

  @doc """
  declare a before_create callback
  """
  defmacro before_create(method_name) when is_atom(method_name) do
    quote do
      @callbacks {:before_create, unquote(method_name)}
    end
  end

  @doc """
  declare a before_update callback
  """
  defmacro before_update(method_name) when is_atom(method_name) do
    quote do
      @callbacks {:before_update, unquote(method_name)}
    end
  end

  @doc """
  declare a before_validation callback
  """
  defmacro before_validation(method_name) when is_atom(method_name) do
    quote do
      @callbacks {:before_validation, unquote(method_name)}
    end
  end

  @doc """
  declare an after_save callback
  """
  defmacro after_save(method_name) when is_atom(method_name) do
    quote do
      @callbacks {:after_save, unquote(method_name)}
    end
  end

  @doc """
  declare an after_create callback
  """
  defmacro after_create(method_name) when is_atom(method_name) do
    quote do
      @callbacks {:after_create, unquote(method_name)}
    end
  end

  @doc """
  declare an after_update callback
  """
  defmacro after_update(method_name) when is_atom(method_name) do
    quote do
      @callbacks {:after_update, unquote(method_name)}
    end
  end

  @doc """
  declare an after_validation callback
  """
  defmacro after_validation(method_name) when is_atom(method_name) do
    quote do
      @callbacks {:after_validation, unquote(method_name)}
    end
  end

  @doc """
  declare an after_find callback
  """
  defmacro after_find(method_name) when is_atom(method_name) do
    quote do
      @callbacks {:after_find, unquote(method_name)}
    end
  end
end
