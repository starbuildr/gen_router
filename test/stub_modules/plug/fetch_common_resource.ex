defmodule GenRouter.Plug.FetchCommonResource do
  @doc false
  def call(conn, _opts) do
    GenRouter.Conn.assign(conn, :common, true)
  end
end
