defmodule GenRouter do
  @moduledoc """
  Router to parse messages,
  modeled by the idea of simplified Plug.Conn router.
  """

  alias GenRouter.Conn

  @doc """
  Match specific route in scope of routes.

  We ensure that all paths and suffixs are matched with slash for consistency.
  """
  @spec match_in_scope(module(), atom(), [{String.t, atom(), atom()}], [atom()], String.t, Conn.t, Keyword.t) :: Conn.t
  def match_in_scope(router_module, scope, routes, scope_pipeline, "/" <> _ = path_suffix, conn, opts) do
    Enum.reduce(routes, :next_scope, fn({path, controller, action}, acc) ->
      if acc === :next_scope do
        result =
          case path do
            %Regex{} = path_regex ->
              Regex.named_captures(path_regex, path_suffix)
            _ ->
              path === path_suffix
          end

        if result === true or (is_map(result) and not Map.equal?(result, %{})) do
          conn = if is_map(result), do: %{conn | params: Map.merge(conn.params, result)}, else: conn
          conn =
            Enum.reduce(scope_pipeline, conn, fn(pipeline, conn) ->
              unless conn.halted do
                apply(router_module, pipeline, [conn, opts])
              else
                conn
              end
            end)

          unless conn.halted do
            apply(controller, :do_action, [action, conn, opts])
          else
            conn
          end
        else
          :next_scope
        end
      else
        acc
      end
    end)
    |> case do
      %Conn{} = conn ->
        conn
      _ ->
        conn = %{conn | __skip__: Map.put(conn.__skip__, scope, true)}
        router_module.do_match(conn, opts)
    end
  end
  def match_in_scope(router_module, scope, routes, scope_pipeline, path_suffix, conn, opts) do
    match_in_scope(router_module, scope, routes, scope_pipeline, "/" <> path_suffix, conn, opts)
  end

  @doc """
  Defines a pipeline to send the connection through.

  See `pipeline/2` for more information.
  """
  defmacro pipe_through(pipes) do
    quote do
      if scope_pipeline = @scope_pipeline do
        @scope_pipeline (unquote(pipes) ++ scope_pipeline)
      else
        raise "cannot define pipe_through at the router level, match must be defined inside a scope"
      end
    end
  end

  @doc """
  Defines default route or a route inside a pipeline.

  See `pipeline/2` for more information.
  """
  defmacro match("*", controller, action) do
    quote do
      @default_route_set true

      def do_match(%Conn{} = conn, opts) do
        unless conn.halted do
          apply(unquote(controller), :do_action, [unquote(action), conn, opts])
        else
          conn
        end
      end

      def scopes, do: @scopes
    end
  end
  defmacro match("/", controller, action) do
    quote do
      if routes = @routes do
        @routes [{"/", unquote(controller), unquote(action)} | routes]
      else
        raise "cannot define match at the router level, match must be defined inside a scope"
      end
    end
  end
  defmacro match(path, controller, action) do
    path =
      if String.contains?(path, ":") do
        "^" <> path <> "$"
        |> String.replace(~r/:([0-9a-z_\-]+)/, "(?<\\g{1}>[0-9a-z_\-]+)")
        |> Regex.compile!()
        |> Macro.escape()
      else
        path
      end

    quote do
      if routes = @routes do
        @routes [{unquote(path), unquote(controller), unquote(action)} | routes]
      else
        raise "cannot define match at the router level, match must be defined inside a scope"
      end
    end
  end

  @doc """
  Defines a plug inside a pipeline.

  See `pipeline/2` for more information.
  """
  defmacro plug(plug, opts \\ []) do
    quote do
      if pipeline = @pipeline do
        @pipeline [{unquote(plug), unquote(opts), true} | pipeline]
      else
        raise "cannot define plug at the router level, plug must be defined inside a pipeline"
      end
    end
  end

  @doc """
  Defines a plug pipeline.

  Pipelines are defined at the router root and can be used
  from any scope.
  """
  defmacro pipeline(pipe, do: block) do
    block =
      quote do
        @pipeline []
        unquote(block)
      end

    compiler =
      quote do
        def unquote(pipe)(%Conn{} = conn, _) do
          Enum.reduce(@pipeline, conn, fn {plug, opts, guards}, acc ->
            apply(plug, :call, [conn, opts])
          end)
        end
        @pipeline nil
      end

    quote do
      try do
        unquote(block)
        unquote(compiler)
      after
        :ok
      end
    end
  end

  @doc """
  Defines scope of routers with pipelines.
  """
  defmacro scope(scope, scope_path, do: block) do
    block =
      quote do
        scopes = @scopes
        @scopes [unquote(scope) | scopes]
        @scope_pipeline []
        @routes []
        unquote(block)
      end

    skip =
      Map.put(%{}, scope, false) |> Macro.escape()

    path_length = String.length(scope_path)
    compiler =
      quote do
        def do_match(
          %Conn{
            path: <<path_prefix::bytes-size(unquote(path_length))>> <> path_suffix,
            __skip__: unquote(skip)
          } = conn, opts
        ) when (path_prefix === unquote(scope_path)) do
          GenRouter.match_in_scope(__MODULE__, unquote(scope), @routes, @scope_pipeline, path_suffix, conn, opts)
        end

        @routes nil
        @scope_pipeline nil
      end

    quote do
      try do
        unquote(block)
        unquote(compiler)
      after
        :ok
      end
    end
  end

  @doc """
  Custom router factory
  """
  defmacro __using__(_opts) do
    quote do
      import GenRouter
      alias GenRouter.Conn

      @behaviour GenRouter.Behaviour

      @pipeline nil
      @scopes []
      @scope_pipeline nil
      @routes nil

      @doc """
      Delegate to scope based matching, generated by router config macros
      """
      @spec match_message(map(), String.t, map(), map(), Keyword.t) :: Conn.t
      def match_message(message, path, scope \\ %{}, assigns \\ %{}, opts \\ []) do
        __MODULE__.match_message(__MODULE__, message, path, scope, assigns, opts)
      end
    end
  end
end
