defmodule QuoteBookWeb.Helpers.Breadcrumb do

  alias QuoteBookWeb.IndexLive
  alias QuoteBookWeb.Router.Helpers, as: Routes

  import Phoenix.LiveView, only: [assign: 2]

  def append_to_socket(socket, name, path) do
    if is_nil(socket.assigns[:breadcrumb]) do
      breadcrumb =
        new()
        |> append("Главная", Routes.live_path(socket, IndexLive))
        |> append(name, path)

      assign(socket, breadcrumb: breadcrumb)
    else
      breadcrumb =
        socket.assigns.breadcrumb
        |> append(name, path)

      assign(socket, breadcrumb: breadcrumb)
    end
  end

  def new do
    :queue.new()
  end

  def append(breadcrumb, name, path) do
    :queue.in({name, path}, breadcrumb)
  end

  def to_list(breadcrumb) do
    breadcrumb
    |> :queue.to_list()
    |> Enum.scan(fn {name, path}, {_last_name, last_path} ->
        {name, Path.join(last_path, path)}
    end)
  end
end
