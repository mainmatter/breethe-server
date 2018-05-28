defmodule JsonApiKeys do
  def camelize(key) do
    {first, rest} =
      Phoenix.Naming.camelize(key)
      |> String.split_at(1)

    String.downcase(first) <> rest
  end

  def underscore(key) do
    Phoenix.Naming.underscore(key)
    |> String.downcase()
  end
end
