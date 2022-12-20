defmodule QuoteBookBot.Utils.UserLoader do
  alias QuoteBook.Book

  # TODO: Лучше скачивать аватарки
  # TODO: Добавить поддержку сообществ
  def insert_new_users_data_to_db() do
    users_ids =
      Book.get_users_from_messages()
      |> Enum.filter(fn x -> x |> elem(1) |> is_nil() end)
      |> Enum.map(&elem(&1, 0))
      |> Enum.reject(&(&1 < 0))

    get_users(users_ids)
    |> photo_100_to_curernt_photo()
    |> Book.insert_users()
  end

  def update_exists_users() do
    users_list = Book.list_users()

    users_list
    |> Stream.map(&Map.fetch!(&1, :id))
    |> Stream.chunk_every(200)
    |> Enum.map(&get_users/1)
    |> List.flatten()
    |> photo_100_to_curernt_photo()
    |> Stream.zip(users_list)
    |> Stream.map(&Book.change_user(elem(&1, 1), elem(&1, 0)))
    |> Enum.filter(fn
      %{changes: changes} when changes == %{} -> false
      _ -> true
    end)
    |> Book.update_users()
  end

  defp get_users(users_ids) do
    VkBot.Api.exec_method("users.get", %{
      "user_ids" => Enum.join(users_ids, ","),
      "fields" => "photo_100"
    })
  end

  defp photo_100_to_curernt_photo(users) do
    users
    |> Stream.map(&Map.put(&1, "current_photo", &1["photo_100"]))
  end
end
