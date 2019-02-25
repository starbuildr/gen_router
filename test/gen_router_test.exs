defmodule GenRouterTest do
  use ExUnit.Case
  doctest GenRouter

  describe "routing" do
    test "with unauthed access" do
      msg = %{
        path: "/",
        message: %{test: "content"},
        scope: %{},
        assigns: %{},
        opts: []
      }
      assert GenRouter.Router.match_message(msg.message, msg.path, msg.scope, msg.assigns, msg.opts).code === 403
    end

    test "with authed access" do
      msg = %{
        path: "/",
        message: %{test: "content"},
        scope: %{},
        assigns: %{authorized: true},
        opts: []
      }
      assert GenRouter.Router.match_message(msg.message, msg.path, msg.scope, msg.assigns, msg.opts).response === "TEST1"
    end

    test "for non-default route in first scope" do
      msg = %{
        path: "/test2",
        message: %{test: "content"},
        scope: %{},
        assigns: %{authorized: true},
        opts: []
      }
      assert GenRouter.Router.match_message(msg.message, msg.path, msg.scope, msg.assigns, msg.opts).response === "TEST2"
    end

    test "for route in second scope" do
      msg = %{
        path: "/stest",
        message: %{test: "content"},
        scope: %{},
        assigns: %{authorized: true},
        opts: []
      }
      assert GenRouter.Router.match_message(msg.message, msg.path, msg.scope, msg.assigns, msg.opts).response === "TEST3"
    end

    test "for route in complex scope" do
      msg = %{
        path: "/stest/complex",
        message: %{test: "content"},
        scope: %{},
        assigns: %{authorized: true},
        opts: []
      }
      assert GenRouter.Router.match_message(msg.message, msg.path, msg.scope, msg.assigns, msg.opts).response === "TEST2"
    end
  end
end