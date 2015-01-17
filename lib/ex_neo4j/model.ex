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
      # Module.register_attribute(__MODULE__ , :before_save          , accumulate: true)
      # Module.register_attribute(__MODULE__ , :before_create        , accumulate: true)
      # Module.register_attribute(__MODULE__ , :after_save           , accumulate: true)
      # Module.register_attribute(__MODULE__ , :after_create         , accumulate: true)
      # Module.register_attribute(__MODULE__ , :after_find           , accumulate: true)
      # Module.register_attribute(__MODULE__ , :validation_functions , accumulate: true)

      @label "#{Mix.env |> Atom.to_string |> String.capitalize}:#{String.replace(Macro.to_string(__MODULE__), ".", ":")}"
      @before_compile ExNeo4j.Model

      field :id, accessible: false, type: :integer
      field :relationships, transient: true
      field :errors, transient: true
      field :created_at, type: :date
      field :updated_at, type: :date
      field :validated, type: :boolean, default: false
    end
  end

  @doc false
  defmacro __before_compile__(env) do
    metadata = ExNeo4j.Model.Metadata.new(env.module)

    quote do
      unquote ExNeo4j.Model.Struct.generate(metadata)
      unquote ExNeo4j.Model.BuildMethod.generate(metadata)
      unquote ExNeo4j.Model.SaveMethod.generate(metadata)
      unquote ExNeo4j.Model.ParseNodeMethod.generate(metadata)
      # unquote ExNeo4j.Model.Methods.generate(metadata)
      # unquote ExNeo4j.Model.Validations.generate(metadata)
      # unquote ExNeo4j.Model.CreateMethod.generate(metadata)
      # unquote ExNeo4j.Model.DeleteMethod.generate(metadata)
      # unquote ExNeo4j.Model.Update.generate(metadata)
      # unquote ExNeo4j.Model.Serialization.generate(metadata)

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

      defmodule Person do
        use ExNeo4j.Model

        field :name
        field :age
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

      defmodule Person do
        use ExNeo4j.Model

        field :name
        relationship :FRIEND_OF, Person
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

  # defmacro validate_with(method_name) when is_atom(method_name) do
  #   quote do
  #     @validation_functions unquote(method_name)
  #   end
  # end

  # defmacro before_save(method_name) when is_atom(method_name) do
  #   quote do
  #     @before_save unquote(method_name)
  #   end
  # end

  # defmacro before_create(method_name) when is_atom(method_name) do
  #   quote do
  #     @before_create unquote(method_name)
  #   end
  # end

  # defmacro after_save(method_name) when is_atom(method_name) do
  #   quote do
  #     @after_save unquote(method_name)
  #   end
  # end

  # defmacro after_create(method_name) when is_atom(method_name) do
  #   quote do
  #     @after_create unquote(method_name)
  #   end
  # end

  # defmacro after_find(method_name) when is_atom(method_name) do
  #   quote do
  #     @after_find unquote(method_name)
  #   end
  # end
end
