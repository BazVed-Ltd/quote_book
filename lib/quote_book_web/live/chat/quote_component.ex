defmodule QuoteBookWeb.QuoteComponent do
  alias QuoteBookWeb.QuoteComponent
  use QuoteBookWeb, :component

  @links_regex ~r/\[(id|club)([0-9]+)\|(.+?)\]/

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
    nested_messages = fetch_nested_messages(assigns.quote)

    author = assigns.quote.from
    author_url = "https://vk.com/id#{author.id}"

    date =
      assigns.quote.inserted_at
      |> DateTime.from_naive!("Etc/UTC")
      |> DateTime.to_unix()

    ~H"""
    <div class='card mb-5'>
      <div class='flex border-b border-zinc-700 pb-2 mb-3'>
        <div>#<%= @quote.quote_id %></div>
        <div id={"#{@quote.quote_id}-date"} class='ml-auto' phx-hook="setTime" data-timestamp={date}></div>
      </div>

      <div class="mb-3">
        <QuoteComponent.nested_messages messages={nested_messages} />
      </div>

      <div class='flex'>
        <div class='ml-auto'>
          Схоронил <a class='text-blue-400' href={author_url}><%= author.name %></a>
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

    from_url =
      if from.id > 2_000_000_000 do
        "https://vk.com/club#{from.id - 2_000_000_000}"
      else
        "https://vk.com/id#{from.id}"
      end

    render_text? = not is_nil(assigns.message.text)

    strings =
      if render_text? do
        assigns.message.text |> format_links
      end

    nested_messages = fetch_nested_messages(assigns.message)

    ~H"""
    <div class="flex">
      <div class="flex-none w-11">
        <img class="w-11 h-11 rounded-full" src={from.current_photo} alt="Аватар"/>
      </div>
      <div class="flex-initial pl-2">
        <a class="text-blue-400" href={from_url}><%= from.name %></a>
        <span id={"#{@message.id}-time"} phx-hook="setTime" data-time-only="true" data-timestamp={@message.date} class="text-gray-500">
        </span>

        <%= if render_text? do %>
          <p class='mb-4 last:mb-0'>
            <%= for string <- strings, do: string %>
          </p>
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
      :doc when assigns.attachment.ext == "mp4" ->
        ~H"""
        <video autoplay loop muted>
          <source src={@attachment.path} type="video/mp4" />
          Ваш браузер не поддерживает HTML5 аудио.
        </video>
        """

      type when type in ~w(photo doc graffiti)a ->
        ~H"<img class='object-scale-down w-full h-full align-middle' src={@attachment.path} />"

      :sticker ->
        ~H"<img class='object-scale-down w-40 h-40 align-middle' src={@attachment.path} />"

      :audio_message ->
        ~H"""
        <audio controls>
          <source src={@attachment.path} type="audio/mpeg">
          <p>Ваш браузер не поддерживает HTML5 аудио.</p>
        </audio>
        """

      _ ->
        ~H"<span><a href={@attachment.path}><%= @attachment.type %></a></span>"
    end
  end

  defp format_links(text) do
    text
    |> split_with_links()
    |> map_to_html()
  end

  defp split_with_links(text) do
    Regex.split(@links_regex, text, include_captures: true)
  end

  defp map_to_html(strings) do
    Enum.flat_map(strings, fn string ->
      result = Regex.run(@links_regex, string)

      if is_nil(result) do
        [string]
      else
        [_, type, id, text] = result

        [
          Phoenix.HTML.raw("<a class=\"text-blue-400\" href=\"https://vk.com/#{type}#{id}\">"),
          text,
          Phoenix.HTML.raw("</a>")
        ]
      end
    end)
  end
end
