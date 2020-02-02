defmodule GenRouter.Controller.TestController do
  use GenRouter.Controller

  plug(GenRouter.Plug.FetchCommonResource)
  plug(GenRouter.Plug.FetchResource when action in [:test4])

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

  @spec test4(GenRouter.Conn.t(), any()) :: GenRouter.Conn.t()
  def test4(conn, _opts) do
    complete(conn, "TEST4")
  end

  @spec test5(GenRouter.Conn.t(), any()) :: GenRouter.Conn.t()
  def test5(%{params: %{"name" => name, "id" => id}} = conn, _opts) do
    complete(conn, "#{name}#{id}")
  end

  @spec not_found(GenRouter.Conn.t(), any()) :: GenRouter.Conn.t()
  def not_found(conn, _opts) do
    complete(conn, nil, %{}, 404)
  end
end
