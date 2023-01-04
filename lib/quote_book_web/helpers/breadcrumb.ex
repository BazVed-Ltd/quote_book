defmodule QuoteBookWeb.Helpers.Breadcrumb do
  def new do
    :queue.new()
  end

  def append(breadcrumb, name, path) do
    :queue.in({name, path}, breadcrumb)
  end

  def to_list(breadcrumb) do
    breadcrumb
    |> :queue.to_list()
    |> Enum.scan({"", ""}, fn {name, path}, {_last_name, last_path} ->
        {name, last_path <> path}
    end)
  end
end
