defmodule QuoteBookWeb.ChatLive do
  use QuoteBookWeb, :live_view

  alias QuoteBook.Book
  alias QuoteBookWeb.QuoteComponent

  @impl true
  def mount(params, _session, socket) do
    peer_id =
      params
      |> Map.fetch!("peer_id")
      |> String.to_integer()

    quotes = Book.list_quotes(peer_id)

    chat = Book.get_chat!(peer_id)

    Process.send_after(self(), :next_cover, Enum.random(2..6) * 1000)

    covers = shuffle_covers(chat.covers)

    {:ok,
     socket
     |> assign(
       chat: chat,
       cover_to_show: covers,
       showed_covers: [],
       quotes: quotes
     )}
  end

  def shuffle_covers(covers) do
    Enum.shuffle(covers)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <%= if @chat.title != nil do %>
      <div class="mt-5">
          <h1 class="text-xl text-center"><%= @chat.title %></h1>
      </div>
    <% end %>
    <%= if @cover_to_show != [] do %>
      <div class="mt-5 h-80">
          <img class="mx-auto h-full" src={List.first(@cover_to_show)} />
      </div>
    <% end %>
    <div class="mt-5">
      <QuoteComponent.quotes quotes={@quotes} />
    </div>
    """
  end

  @impl true
  def handle_info(:next_cover, socket) do
    Process.send_after(self(), :next_cover, Enum.random(2..6) * 1000)

    with [popped | rest] <- socket.assigns.cover_to_show,
         true <- rest != [] do
      {:noreply,
       assign(socket, cover_to_show: rest, showed_covers: [popped | socket.assigns.showed_covers])}
    else
      _err ->
        {:noreply,
         assign(socket,
           cover_to_show: socket.assigns.cover_to_show ++ socket.assigns.showed_covers,
           showed_covers: []
         )}
    end
  end
end
