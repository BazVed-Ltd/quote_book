defmodule QuoteBookBot.Utils.MapExtensions do
  @moduledoc false

  @spec update_or_nothing(map, any, any) :: map
  @doc """
  Буквально `Map.update/4`, но без добавления стандартного значения.
  """
  def update_or_nothing(map, key, fun) do
    case Map.fetch(map, key) do
      {:ok, value} -> Map.put(map, key, fun.(value))
      :error -> map
    end
  end
end
