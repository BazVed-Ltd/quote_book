defmodule QuoteBookWeb.SignInLive do
  use QuoteBookWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="mt-3 flex flex-col">
      <div class="card mx-auto px-9">
        <h1 class="text-2xl text-center">Войти</h1>
        <div id="vk-login" class="mx-auto mt-5 max-w-full" phx-hook="vkLoginHook"></div>
      </div>
    </div>
    """
  end
end
