defmodule GenRouter.Behaviour do
  @moduledoc """
  Callbacks for custom implementation for the Router.
  """

  @type router :: module()
  @type message :: map()
  @type path :: String.t
  @type scope :: map()
  @type assigns :: map()

  @type view :: module()
  @type template :: String.t
  @type params :: map()
  @type opts :: Keyword.t

  @doc """
  Function which converts generic message into GenRouter.Conn structure
  then match it according to the router specification.
  """
  @callback match_message(router, message, path, scope, assigns, opts) :: %GenRouter.Conn{}

  @doc """
  Renders the view and deliver response to the end client.
  """
  @callback deliver(%GenRouter.Conn{}, view, template, params, opts) :: %GenRouter.Conn{}
end
