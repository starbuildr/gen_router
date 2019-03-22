defmodule GenRouter.Plug.FetchResource do
  @doc false
  def call(conn, _opts) do
    GenRouter.Conn.assign(conn, :user, %{"name" => "Tester"})
  end
end
