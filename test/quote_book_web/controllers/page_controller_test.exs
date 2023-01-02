defmodule QuoteBookWeb.PageControllerTest do
  use QuoteBookWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Каналы"
  end
end
