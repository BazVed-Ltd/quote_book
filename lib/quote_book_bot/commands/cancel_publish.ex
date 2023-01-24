defmodule QuoteBookBot.Commands.CancelPublish do
  @moduledoc """
  /отмена <id> — отменить публикацию цитаты.

  Отменить публикацию цитаты можно только если она была опубликована не более недели назад.
  """
  import VkBot.{CommandsManager, Request}
  require VkBot.CommandsManager
  alias QuoteBook.Book

  @arg_error_text "Единственный аргумент команды — айди цитаты, публикацю которой вы хотите отменить."
  @not_in_quote_text "Вы не можете отменить публикацию, т.к. вас нет в цитате."
  @a_lot_of_time_ago_text "Цитата опубликована слишком давно. Теперь это история."

  #                          d    h    m    s
  @unpublish_time_in_seconds 7 * 24 * 60 * 60

  defcommand request,
    predicate: [on_text: "/отмена", in: :chat] do
    message = Map.fetch!(request, :message)

    from_id = Map.fetch!(message, "from_id")
    text = Map.fetch!(message, "text")

    reply_text =
      with {:ok, id} <- get_id_from_text(text),
           {:ok, quote_message} <- Book.fetch_published_quote(id),
           users = Book.get_users_from_published(id),
           user_ids = Enum.map(users, fn user -> user.id end),
           :ok <- user_in_quote?(from_id, user_ids),
           :ok <- can_unpublish_by_time?(quote_message) do
        _quote_message = Book.cancel_publish_quote(quote_message)

        """
        Вы отменили публикацию этой цитаты.
        """
      else
        {:error, error} ->
          error
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
      {_id, _remainder} -> {:error, @arg_error_text}
      :error -> {:error, @arg_error_text}
    end
  end

  defp fetch_first_arg([_command, arg]), do: {:ok, arg}
  defp fetch_first_arg(_), do: {:error, @arg_error_text}

  defp user_in_quote?(user_id, user_ids) do
    if user_id in user_ids do
      :ok
    else
      {:error, @not_in_quote_text}
    end
  end

  defp can_unpublish_by_time?(quote_message) do
    # TODO: добавить колонку published_at
    updated = DateTime.from_naive!(quote_message.updated_at, "Etc/UTC")
    now = DateTime.now!("Etc/UTC")

    if DateTime.diff(now, updated) < @unpublish_time_in_seconds do
      :ok
    else
      {:error, @a_lot_of_time_ago_text}
    end
  end
end
