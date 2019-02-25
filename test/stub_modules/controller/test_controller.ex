defmodule GenRouter.Controller.TestController do
  import GenRouter.Conn

  @spec test1(GenRouter.Conn.t(), any()) :: GenRouter.Conn.t()
  def test1(conn, _opts) do
    complete(conn, "TEST1")
  end

  @spec test2(GenRouter.Conn.t(), any()) :: GenRouter.Conn.t()
  def test2(conn, _opts) do
    complete(conn, "TEST2")
  end

  @spec test3(GenRouter.Conn.t(), any()) :: GenRouter.Conn.t()
  def test3(conn, _opts) do
    complete(conn, "TEST3")
  end

  @spec not_found(GenRouter.Conn.t(), any()) :: GenRouter.Conn.t()
  def not_found(conn, _opts) do
    complete(conn, nil, %{}, 404)
  end
end
