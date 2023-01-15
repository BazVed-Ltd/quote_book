defmodule QuoteBookBot.Commands.RenderQuote do
  @moduledoc """
  /сь <id> — отправить картинку с цитатой
  """
  alias QuoteBookBot.Utils.QuoteToPNG
  import VkBot.{CommandsManager, Request}
  require VkBot.CommandsManager

  @limit_in_ms 1 * 60 * 60 * 1000

  @limit_text "В час можно делать не больше 10 рендеров."
  @error_text "Вторым аргументом должен быть айди цитаты."

  defcommand request,
    predicate: [on_text: "/сь", in: :chat] do
    args =
      request.message
      |> Map.fetch!("text")
      |> String.split(" ")

    user_id = request.message["from_id"]
    with {:ok, id} <- parse_args(args),
         {:allow, _} <- Hammer.check_rate("render_quote:#{user_id} ", @limit_in_ms, 10) do
      quote_message = QuoteBook.Book.get_quote(request.message["peer_id"], id)
      rendered_quote = render_quote(quote_message)
      reply_message(request, "", attachment: rendered_quote.vk_path)
    else
      {:error, error_message} -> reply_message(request, error_message)
      {:deny, _limit} -> reply_message(request, @limit_text)
    end
  end

  defp parse_args([_command, id]) do
    case Integer.parse(id) do
      {id, ""} ->
        {:ok, id}

      _error ->
        {:error, @error_text}
    end
  end

  defp parse_args(_) do
    {:error, @error_text}
  end

  defp render_quote(quote_message) do
    QuoteToPNG.convert(quote_message)
  end
end
