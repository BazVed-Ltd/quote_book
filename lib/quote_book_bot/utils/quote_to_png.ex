defmodule QuoteBookBot.Utils.QuoteToPNG do
  @moduledoc """
  Конвертация цитаты в картинку.
  """
  alias QuoteBook.Book
  alias QuoteBookBot.Utils.Links

  defp renders_directory do
    Application.get_env(:quote_book, :renders_directory)
  end

  defp screenshoter_url do
    Application.get_env(:quote_book, :screenshoter_url)
  end

  defp back_url do
    Application.get_env(:quote_book, :back_url)
  end

  defp secret_key do
    Application.get_env(:quote_book, :screenshoter_key)
  end

  defp json_library do
    Phoenix.json_library()
  end

  @doc """
  Возвращает отрендеренную цитату, загруженную на сервер в вк.
  """
  def convert(quote_message) do
    rendered_quote = Book.get_rendered_quote(quote_message.quote_id)

    rendered_quote =
      if is_nil(rendered_quote) do
        {:ok, rendered_quote} =
          render(quote_message)
          |> upload_render()
          |> Book.create_rendered_quote()

        rendered_quote
      else
        # 1. Check need rerender.
        # 1.1. Rerender, if needed.
        # 2. Return path.
        users_in_quote =
          Book.get_users_from_message(quote_message.peer_id, quote_message.quote_id)

        rerender? =
          Enum.any?(users_in_quote, fn user -> user.updated_at > rendered_quote.updated_at end)

        if rerender? do
          updated_fields =
            render(quote_message)
            |> Map.drop([:id])
            |> upload_render()

          {:ok, rendered_quote} = Book.update_rendered_quote(rendered_quote, updated_fields)
          rendered_quote
        else
          rendered_quote
        end
      end

    rendered_quote
  end

  defp render(quote_message) do
    quote_path =
      Path.join(renders_directory(), "#{quote_message.peer_id}-#{quote_message.quote_id}.png")

    download_quote(quote_message)
    |> save_quote(quote_path)

    %{id: quote_message.quote_id, local_path: quote_path}
  end

  defp download_quote(quote_message) do
    path = Links.quote_path(quote_message)

    query = URI.encode_query([bot: true, bot_key: secret_key()])

    body =
      json_library().encode!(%{
        selector: "#quote",
        url: "#{back_url()}#{path}?#{query}"
      })

    headers = [{"Content-type", "application/json"}]

    HTTPoison.post!(screenshoter_url(), body, headers)
    |> Map.fetch!(:body)
  end

  defp upload_render(rendered_quote) do
    rendered_quote
    |> Map.put(:vk_path, VkBot.Uploader.upload_photo(rendered_quote.local_path))
  end

  defp save_quote(data, path) do
    File.write!(path, data)
  end
end
