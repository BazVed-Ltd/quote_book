defmodule QuoteBookWeb.ChatLive do
  use QuoteBookWeb, :live_view

  import Phoenix.LiveView

  alias QuoteBook.Book
  alias QuoteBookWeb.QuoteComponent

  @impl true
  def mount(params, _session, socket) do
    peer_id = Map.fetch!(params, "peer_id")

    chat = get_chat_by_name_or_id(peer_id)

    if is_nil(chat) do
      {:ok,
       socket
       |> push_redirect(to: "/")
       |> put_flash(:error, "ОШИБКА!!! Нет такого чата")}
    else
      quotes = Book.list_quotes(chat.id)

      {:ok,
       socket
       |> assign(chat: chat, quotes: quotes)
       |> assign_title(chat.title)
       |> assign_covers(chat.covers)}
    end
  end

  defp get_chat_by_name_or_id(text) do
    case Integer.parse(text) do
      {peer_id, ""} -> Book.get_chat(peer_id)
      _otherwise -> Book.get_chat_by_slug(text)
    end
  end

  defp assign_title(socket, nil) do
    assign(socket, render_title?: false)
  end

  defp assign_title(socket, title) do
    assign(socket, render_title?: true, title: title, page_title: title)
  end

  defp assign_covers(socket, []) do
    assign(socket, render_cover?: false)
  end

  defp assign_covers(socket, [cover]) do
    assign(socket,
      render_cover?: true,
      cover: cover
    )
  end

  defp assign_covers(socket, covers) do
    cover_queue = Enum.reduce(Enum.shuffle(covers), :queue.new(), &:queue.in(&1, &2))

    {current, next_covers} = queue_cycle(cover_queue)

    Process.send_after(self(), :next_cover, Enum.random(7..10) * 1000)

    assign(socket,
      render_cover?: true,
      cover: current,
      next_covers: next_covers
    )
  end

  @impl true
  def render(assigns) do
    ~H"""
    <%= if @render_title? do %>
      <div class="mt-5">
          <h1 class="text-xl text-center"><%= @title %></h1>
      </div>
    <% end %>
    <%= if @render_cover? do %>
      <div class="mt-5 h-80">
          <%= if String.ends_with?(@cover, "mp4") do %>
            <video class="mx-auto h-full" src={@cover} type="video/mp4" autoplay loop muted />
          <% else %>
            <img class="mx-auto h-full" src={@cover} />
          <% end %>
      </div>
    <% end %>
    <div class="mt-5">
      <QuoteComponent.quotes quotes={@quotes} />
    </div>
    """
  end

  @impl true
  def handle_info(:next_cover, socket) do
    Process.send_after(self(), :next_cover, Enum.random(7..10) * 1000)

    {current, next_covers} = queue_cycle(socket.assigns.next_covers)

    {:noreply,
     assign(socket,
       render_cover?: true,
       cover: current,
       next_covers: next_covers
     )}
  end

  defp queue_cycle(queue) do
    {{_, item}, rest} = :queue.out(queue)
    new_queue = :queue.in(item, rest)

    {item, new_queue}
  end
end
