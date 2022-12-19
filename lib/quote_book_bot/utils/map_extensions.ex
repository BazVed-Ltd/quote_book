defmodule QuoteBookBot.Utils.MapExtensions do
  @doc """
  Literally `Map.update/4`, but without adding default value.
  """
  def update_or_nothing(map, key, fun) do
    case Map.fetch(map, key) do
      {:ok, value} -> Map.put(map, key, fun.(value))
      :error -> map
    end
  end
end
