defmodule GenRouter.Conn do
  @moduledoc """
  Structure which represents connection with Telegram bot.
  Inspired by %Plug.Conn{}, adapted for bots.

  Attributes:

    * __skip__: system buffer to keep track of skipped scopes;
    * path: route to controller which should handle this object;
    * params: payload which will be passed to controller;
    * assigns: non-parsed data assigned by a system (auth, etc);
    * scope: local scope of current request, clears for each new route;
    * code: response code, we use common HTTP codes, currently only 200 is supported;
    * response: response payload, usually JSON;
    * halted: stop the pipeline execution if conn was settled.
  """

  defstruct [
    __skip__: %{},
    path: "/",
    params: %{},
    assigns: %{},
    scope: %{},
    code: nil,
    response: nil,
    halted: false
  ]

  @type t :: %GenRouter.Conn{}

  @doc """
  Build Conn object with system fields
  """
  @spec build(module(), map()) :: t
  def build(router_module, %{path: path, params: params, assigns: assigns, scope: scope}) do
    %GenRouter.Conn{
      path: path,
      params: params,
      assigns: assigns,
      scope: scope
    } |> reset_router_matches(router_module)
  end

  @doc """
  Assign variable to current request.
  """
  @spec assign(t, atom(), any()) :: t
  def assign(%GenRouter.Conn{assigns: assigns} = conn, key, value) do
    assigns = Map.put(assigns, key, value)
    %{conn | assigns: assigns}
  end

  @doc """
  Update state and complete the current request.
  """
  @spec complete(t, String.t | nil, map(), integer()) :: t
  def complete(conn, response \\ nil, scope \\ %{}, code \\ 200)
  def complete(%GenRouter.Conn{} = conn, response, scope, code) when is_map(scope) and is_integer(code) do
    %{conn | response: response, scope: scope, code: code}
    |> halt()
  end

  @doc """
  Put the next path after the current request.

  It unhalts settled conn, so all the pipelines will be executed again.
  """
  @spec forward(t, String.t, map(), Keyword.t) :: t
  def forward(%GenRouter.Conn{} = conn, path \\ "/", scope \\ %{}, opts \\ []) when is_bitstring(path) do
    router_module =
      Keyword.get(opts, :router_module, false) ||
      Application.get_env(:gen_router, GenRouter.Conn)
      |> Keyword.fetch!(:default_router)

    %{conn | path: path, scope: scope, code: 302, halted: false}
    |> reset_router_matches(router_module)
    |> router_module.do_match(opts)
  end

  @doc """
  Halt execution pipeline, Conn is settled.
  """
  @spec halt(t) :: t
  def halt(%GenRouter.Conn{} = conn)  do
    %{conn | halted: true}
  end

  @doc """
  Reset router matching pipeline
  """
  @spec reset_router_matches(t, module()) :: t
  def reset_router_matches(conn, router_module) do
    skip_router_scopes = Enum.reduce(router_module.scopes(), %{}, &(Map.put(&2, &1, false)))
    %{conn | __skip__: skip_router_scopes}
  end
end
