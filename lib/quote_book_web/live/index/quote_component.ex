defmodule QuoteBookWeb.QuoteComponent do
  alias QuoteBookWeb.QuoteComponent
  use QuoteBookWeb, :component

  alias __MODULE__

  def quote(assigns) do
    ~H"""
    <QuoteComponent.quote_rec quote={@quote} />
    """
  end

  def quote_rec(assigns) do
    case assigns.quote do
      %{fwd_messages: fwd_messages} when is_list(fwd_messages) ->
        ~H"""
        <div>
          <div><%= @quote.text %></div>
          <div>
            <%= for attachment <- @quote.attachments do%>
              <div><img src={attachment.path} /></div>
            <% end %>
          </div>
          <%= for quote_message <- @quote.fwd_messages do %>
            <div class="nested">
              <QuoteComponent.quote_rec quote={quote_message} />
            </div>
          <% end %>
        </div>
        """

      %{reply_message: %QuoteBook.Book.Message{}} ->
        ~H"""
        <div>
          <div><%= @quote.text %></div>
          <div>
            <%= for attachment <- @quote.attachments do%>
              <div><img src={attachment.path} /></div>
            <% end %>
          </div>
          <div class="nested">
            <QuoteComponent.quote_rec quote={@quote.reply_message} />
          </div>
        </div>
        """

      _ ->
        ~H"""
        <div><%= @quote.text %></div>
        <div>
          <%= for attachment <- @quote.attachments do%>
            <div><img src={attachment.path} /></div>
          <% end %>
        </div>
        """
    end
  end
end
