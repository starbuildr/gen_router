# GenRouter

Sometimes you need a routing capabilities which can work with a generic connection object
and you can't use existing routing modules included in `Phoenix` and `Plug.Router` packages.

One of the use cases is the routing of messages for chatbots.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `gen_router` to your list of dependencies in `mix.exs`:

```elixir 
def deps do
  [
    {:gen_router, "~> 0.1"}
  ]
end
```

## Usage

[Hex docs](https://hexdocs.pm/gen_router)

Router configuration is similar to Phoenix routing system, but we don't support HTTP methods and define only `match` rules.

You need to define `match_message` and `deliver` callbacks according to `GenRouter.Behaviour` behviour.

### match_message

Transforms generic input into %GenRouter.Conn{} object and execute the routing process.

Arguments:

* `router_module` - router module which implements GenRouter
* `message` - client request payload, %{} by default
* `path` - client request path
* `scope` - client request scope, %{} by default
* `assigns` - data assigned by the system (authorization, locale etc)
* `opts` - request options

### deliver

Replacement of `render` function in Phoenix routing and responsible for delivering routing results to your clients.

Arguments:

* `conn` - connection object
* `view` - view module which will be used for rendering
* `template` - name of template to render
* `params` - rendering params
* `opts` - delivery options

###

Sample router:

```
defmodule App.Router do
  use GenRouter
  alias App.Controller.FirstController
  alias App.Controller.Model4Controller
  alias App.Controller.ErrorController

  pipeline :authed do
    plug App.Plug.Authorize
  end

  scope :default, "/" do
    pipe_through [:authed]

    match "/", FirstController, :action1
    match "/action2", FirstController, :action2
    match "/model3", FirstController, :action3
  end

  scope :model4_scope, "/model4" do
    pipe_through [:authed]

    match "/", Model4Controller, :index
  end

  match "*", ErrorController, :not_found

  @impl true
  def match_message(router_module, message, path, scope, assigns, opts) do
    conn =
      GenRouter.Conn.build(router_module, %{
        path: path,
        params: %{message: message},
        assigns: assigns,
        scope: scope
      })
    router_module.do_match(conn, opts)
  end

  @impl true
  def deliver(conn, _view, _template, _params, _opts) do
    conn
  end
end
```

## Other

__This library is in it's early beta, use on your own risk. Pull requests / reports / feedback are welcome.__

