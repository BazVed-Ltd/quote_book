defmodule QuoteBookWeb.QuoteComponent do
  use QuoteBookWeb, :component

  alias Phoenix.HTML

  @links_regex ~r/\[(id|club)([0-9]+)\|(.+?)\]/

  def quotes(assigns) do
    ~H"""
    <ul class="flex flex-col max-w-lg px-3 sm:px-0 mx-auto">
      <%= for quote_message <- @quotes do %>
        <li>
          <.message_quote quote={quote_message} />
        </li>
      <% end %>
    </ul>
    """
  end

  def message_quote(assigns) do
    nested_messages = fetch_nested_messages(assigns.quote)

    author = assigns.quote.from
    author_url = "https://vk.com/id#{author.id}"

    date =
      assigns.quote.inserted_at
      |> DateTime.from_naive!("Etc/UTC")

    date_str =
      date
      |> DateTime.add(3, :hour)
      |> Calendar.strftime("%d.%m.%Y в %H:%M")

    ~H"""
    <div class='card mb-5'>
      <div class='flex border-b border-zinc-700 pb-2 mb-3'>
        <div>#<%= @quote.quote_id %></div>
        <div
          id={"quote-#{@quote.quote_id}-date"}
          class='ml-auto'
          phx-hook="setTime"
          data-timestamp={DateTime.to_unix(date)}
        ><%= date_str %></div>
      </div>

      <div class="mb-3">
        <.nested_messages messages={nested_messages} top_level={true} />
      </div>

      <div class='flex'>
        <div class='ml-auto'>
          Схоронил <a href={author_url}><%= author.name %></a>
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
    top_level = Map.get(assigns, :top_level, false)

    ~H"""
    <ul>
      <%= for [prev, message] <- Stream.chunk_every([nil | @messages], 2, 1) do %>
        <% collapse = prev && prev.from.id == message.from.id && message.date - prev.date < 120 %>
        <li class="mt-4 first:mt-0">
          <.nested_message message={message} top_level={top_level} collapse={collapse}/>
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
        assigns.message.text |> format_text
      end

    nested_messages = fetch_nested_messages(assigns.message)

    date_str =
      assigns.message.date
      |> DateTime.from_unix!()
      |> DateTime.add(3, :hour)
      |> Calendar.strftime("%H:%M")

    ~H"""
    <div class={"grid gap-x-2 " <> if @collapse, do: "grid-cols-collapsed-message", else: "grid-cols-message"}>
      <%= unless @collapse do %>
        <div class="w-11 row-span-2">
          <img class="w-11 h-11 rounded-full" src={from.current_photo} alt="Аватар"/>
        </div>

        <div>
          <a href={from_url}><%= from.name %></a>
        <%= unless @top_level, do: HTML.raw "</div><div>" %>
          <span
            id={"message-#{@message.id}-time"}
            phx-hook="setTime"
            data-time-only="true"
            data-timestamp={@message.date}
            class="text-gray-500"
            ><%= date_str %></span>
        </div>
      <% end %>


      <div class={(unless @top_level, do: "col-span-2", else: "") <> " " <> if @top_level and @collapse, do: "ml-top-collapsed", else: "" }>
        <%= if render_text? do %>
          <p class='mb-4 last:mb-0'>
            <%= for string <- strings, do: string %>
          </p>
        <% end %>

        <%= if @message.attachments != [] do %>
          <div class="mt-2">
            <.attachments attachments={@message.attachments} />
          </div>
        <% end %>
      </div>
    </div>
    <%= if nested_messages != [] do %>
      <div class={"ml-1 mt-4 " <> if @top_level, do: "pl-nested", else: ""}>
          <div class='border-l-2 border-zinc-600 pl-1'>
            <.nested_messages messages={nested_messages} />
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
          <.attachment attachment={attachment} />
        </li>
      <% end %>
    </ul>
    """
  end

  def attachment(assigns) do
    case assigns.attachment.type do
      :doc when assigns.attachment.ext == "mp4" ->
        ~H"""
        <video autoplay loop muted src={"/#{assigns.attachment.path}"} type='video/mp4' />
        """

      type when type in ~w(photo doc graffiti)a ->
        ~H"""
        <img class='object-scale-down w-full h-full align-middle' src={"/#{assigns.attachment.path}"} />
        """

      :sticker ->
        ~H"""
        <img class='object-scale-down w-40 h-40 align-middle' src={"/#{assigns.attachment.path}"} />
        """

      :audio_message ->
        ~H"""
        <audio controls src={"/#{assigns.attachment.path}"} type='audio/mpeg' />
        """

      _ ->
        ~H"""
        <span><a href={"/#{assigns.attachment.path}"}><%= @attachment.type %></a></span>
        """
    end
  end

  defp format_text(text) do
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
        insert_new_lines(string)
      else
        [_, type, id, text] = result

        [
          HTML.raw("<a href=\"https://vk.com/#{type}#{id}\">"),
          insert_new_lines(text),
          HTML.raw("</a>")
        ]
        |> List.flatten()
      end
    end)
  end

  defp insert_new_lines(text) do
    text
    |> String.split("\n")
    |> Enum.intersperse(HTML.raw("<br />"))
  end
end
