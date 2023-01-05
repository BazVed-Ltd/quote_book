# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     QuoteBook.Repo.insert!(%QuoteBook.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

# Users
alias QuoteBook.Book.User

durov_photo =
  "https://sun3-12.userapi.com/s/v1/if1/3skihU8qE8H4URxyGbGi1FFTJVntIecGdA-VhTAvXwfj8Neh18E5Qur7piejQsmdOB5Gd6xx.jpg?size=100x100&quality=96&crop=514,119,337,337&ava=1"

user = %User{
  id: 1,
  current_photo: durov_photo,
  name: "Павел Дуров"
}

QuoteBook.Repo.insert!(user)

group_photo =
  "https://sun3-17.userapi.com/s/v1/if1/-KtBexxCseHjbF2KHkGe39sIKDnFws1s2jZGoSyu6VVi60svhEBzHdFpxtSTMVnSjHhc_x0h.jpg?size=100x100&quality=96&crop=20,20,560,560&ava=1"

group = %User{
  id: 2_000_000_001,
  current_photo: group_photo,
  name: "ВКонтакте API"
}

QuoteBook.Repo.insert!(group)

# Chats
alias QuoteBook.Book.Chat

title = "🤓Тестовая группа!!!🤓"

chat = %Chat{
  id: 2_000_000_001,
  title: title,
  slug: Slug.slugify(title)
}

QuoteBook.Repo.insert!(chat)

# Message
alias QuoteBook.Book.Message

message_builder = fn from_id, text ->
  %{
    from_id: from_id,
    text: text,
    peer_id: chat.id,
    date: DateTime.now!("Etc/UTC") |> DateTime.to_unix()
  }
end

%{

}
photo = %{
  "type" => "photo",
  "photo" =>  %{
    "sizes" => [
      %{
        "width" => 1,
        "height" => 1,
        "url" => "https://sun3-12.userapi.com/s/v1/if1/FB03xyGgrEqPBo0A9LJRFj8LyDeGPvM7NtgPpz_cpDPbhU55jFa1ArsDOHkUnVt3SpEMUHYA.jpg?size=337x337&quality=96&crop=514,119,337,337&ava=1"
      }
    ]
  }
}
|> QuoteBookBot.Utils.Attachments.load_attachment()

msg1 =
  message_builder.(user.id, "Ну-ка! Поставь это фото мне на аву!")
  |> Map.put(:attachments, [photo])

msg2 =
  message_builder.(group.id, "Щас сделаю")
  |> Map.put(:reply_message, msg1)

msg3 = message_builder.(user.id, "Капец я красавчик")

msg4 =
  message_builder.(user.id, "Умные мысли часто преследуют его. Но он быстрее")
  |> Map.put(:fwd_messages, [msg1, msg3])

quote_message =
  message_builder.(user.id, "/сьлржалсч")
  |> Map.put(:fwd_messages, [msg1, msg2, msg3, msg4])

Message.changeset(%Message{}, quote_message)
|> QuoteBook.Repo.insert!()
