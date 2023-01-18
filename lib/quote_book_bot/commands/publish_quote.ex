defmodule QuoteBookBot.Commands.PublishQuote do
  @moduledoc """
  /публикация <id> — опубликовать цитату.
  """
  import VkBot.{CommandsManager, Request}
  require VkBot.CommandsManager
  alias QuoteBook.Book

  @arg_error_text "Единственный аргумент команды — айди цитаты, которую вы хотите опубликовать"

  defcommand request,
    predicate: [on_text: "/публикация", in: :chat] do
    message = Map.fetch!(request, :message)

    peer_id = Map.fetch!(message, "peer_id")
    text = Map.fetch!(message, "text")

    reply_text =
      with {:ok, quote_id} <- get_id_from_text(text),
           {:ok, quote_message} <- Book.fetch_quote(peer_id, quote_id),
           users = Book.get_users_from_message(peer_id, quote_id),
           :ok <- check_all_members(peer_id, users) do
        _quote_message = Book.publish_quote(quote_message)

        users = users |>  Enum.reject(&Kernel.>(&1.id, 2_000_000_000)) |> Enum.uniq()

        """
        Цитата успешно опубликована!
        Пользователи #{create_mentions(users)} могут отменить публикацию этой \
        цитаты в течение следующей недели.
        """
      else
        {:error, error} ->
          error

        {:not_a_member, users} ->
          """
          Эти пользователи не состоят в чате и цитаты с ними не могут быть \
          опубликованы:
          #{create_mentions(users)}
          """
      end

    reply_message(request, reply_text)
  end

  defp get_id_from_text(text) do
    args = String.split(text, " ")

    with {:ok, second_arg} <- fetch_first_arg(args),
         {id, ""} <- Integer.parse(second_arg) do
      {:ok, id}
    else
      {:error, _message} = error -> error
      {_id, _remainder} -> @arg_error_text
      :error -> @arg_error_text
    end
  end

  defp fetch_first_arg([_command, arg]), do: {:ok, arg}
  defp fetch_first_arg(_), do: {:error, @arg_error_text}

  defp check_all_members(chat_id, users) do
    chat_members_ids =
      Book.get_chat_members(chat_id)
      |> Enum.map(fn user -> user.id end)
      |> MapSet.new()

    users_ids =
      users
      |> Stream.map(fn user -> user.id end)
      |> Enum.reject(fn user_id -> user_id > 2_000_000 end)
      |> MapSet.new()

    if MapSet.subset?(users_ids, chat_members_ids) do
      :ok
    else
      not_in_chat =
        MapSet.difference(users_ids, chat_members_ids)
        |> Enum.map(fn user_id -> Enum.find(users, fn user -> user.id == user_id end) end)

      {:not_a_member, not_in_chat}
    end
  end

  defp create_mentions(users) do
    users
    |> Enum.map_join(", ", fn user -> "[id#{user.id}|#{user.name}]" end)
  end
end
