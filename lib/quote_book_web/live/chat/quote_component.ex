defmodule QuoteBookWeb.QuoteComponent do
  alias QuoteBookWeb.QuoteComponent
  use QuoteBookWeb, :component

  alias __MODULE__

  def quotes(assigns) do
    ~H"""
    <ul class="flex flex-col max-w-lg px-3 sm:px-0 mx-auto">
      <%= for quote_message <- @quotes do %>
        <li>
          <QuoteComponent.quote quote={quote_message} />
        </li>
      <% end %>
    </ul>
    """
  end

  def quote(assigns) do
    date = Calendar.strftime(assigns.quote.inserted_at, "%x %H:%M")
    nested_messages = fetch_nested_messages(assigns.quote)

    author = assigns.quote.from
    author_full_name = "#{author.first_name} #{author.last_name}"
    author_url = "https://vk.com/id#{author.id}"

    ~H"""
    <div class='card mb-5'>
      <div class='flex border-b border-zinc-700 pb-2 mb-3'>
        <div>#<%= @quote.quote_id %></div>
        <div class='ml-auto'>
          <%= date %>
        </div>
      </div>

      <div>
        <QuoteComponent.nested_messages messages={nested_messages} />
      </div>

      <div class='flex'>
        <div class='ml-auto'>
          Схоронил <a class='text-blue-400' href={author_url}><%= author_full_name %></a>
        </div>
      </div>
    </div>
    """
  end

  defp fetch_nested_messages(message) do
    case message do
      %{fwd_messages: fwd_messages} when is_list(fwd_messages) ->
        fwd_messages

      %{reply_message: %QuoteBook.Book.Message{} = message} ->
        [message]

      _ ->
        []
    end
  end

  def nested_messages(assigns) do
    ~H"""
    <ul>
      <%= for message <- @messages do %>
        <li class="mb-4 last:mb-0">
          <QuoteComponent.nested_message message={message} />
        </li>
      <% end %>
    </ul>
    """
  end

  def nested_message(assigns) do
    from = assigns.message.from
    from_full_name = "#{from.first_name} #{from.last_name}"
    from_url = "https://vk.com/id#{from.id}"

    nested_messages = fetch_nested_messages(assigns.message)

    ~H"""
    <div class="flex">
      <div class="flex-none w-11">
        <img class="w-11 h-11 rounded-full" src={from.current_photo} />
      </div>
      <div class="flex-initial pl-2">
        <a class="text-blue-400" href={from_url}><%= from_full_name %></a>

        <%= unless is_nil(@message.text) do %>
          <p class='mb-4 last:mb-0'><%= @message.text %></p>
        <% end %>

        <%= if @message.attachments != [] do %>
          <div class="mt-2">
            <QuoteComponent.attachments attachments={@message.attachments} />
          </div>
        <% end %>
      </div>
    </div>
    <%= if nested_messages != [] do %>
      <div class="ml-3 mt-4">
          <div class='border-l border-zinc-600 pl-4'>
            <QuoteComponent.nested_messages messages={nested_messages} />
          </div>
      </div>
    <% end %>
    """
  end

  def attachments(assigns) do
    ~H"""
    <ul class="flex flex-wrap gap-1">
      <%= for attachment <- @attachments do %>
        <li>
          <QuoteComponent.attachment attachment={attachment} />
        </li>
      <% end %>
    </ul>
    """
  end

  def attachment(assigns) do
    case assigns.attachment.type do
      type when type in ~w(photo doc graffiti)a ->
        ~H"<img class='object-scale-down w-full h-full align-middle' src={@attachment.path} />"

      :sticker ->
        ~H"<img class='object-scale-down w-40 h-40 align-middle' src={@attachment.path} />"

      _ ->
        ~H"<span><a href={@attachment.path}><%= @attachment.type %></a></span>"
    end
  end
end