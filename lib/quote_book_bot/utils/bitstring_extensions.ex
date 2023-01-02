defmodule QuoteBookBot.Utils.BitstringExtensions do
  @moduledoc false

  @spec chunks(bitstring, pos_integer()) :: [bitstring()]
  @doc """
  См. `Enum.chunk_every/2`.
  """
  def chunks(binary, n) do
    do_chunks(binary, n, [])
  end

  defp do_chunks(binary, n, acc) when bit_size(binary) <= n do
    Enum.reverse([binary | acc])
  end

  defp do_chunks(binary, n, acc) do
    <<chunk::size(n), rest::bitstring>> = binary
    do_chunks(rest, n, [<<chunk::size(n)>> | acc])
  end
end
