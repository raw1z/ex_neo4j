ExUnit.start
Code.require_file "../support/mock.exs", __ENV__.file
Mock.start_link

defmodule Person do
  use ExNeo4j.Model
  field :name, required: true
  field :email, required: true, unique: true, format: ~r/\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b/
  field :age, type: :integer

  relationship :FRIEND_OF, Person
  relationship :MARRIED_TO, Person
end
