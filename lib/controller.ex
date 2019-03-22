defmodule GenRouter.Controller do
  @moduledoc """
  Boilerplate to define controller in scope of GenRouter.
  """

  @doc """
  Callable plugs in controllers.
  """
  defmacro plug(ast, opts \\ []) do
    {plug, guard} =
      case ast do
        {:when, _, [plug | guard]} -> {plug, guard}
        plug -> {plug, true}
      end

    quote do
      @plugs {unquote(plug), unquote(opts), unquote(Macro.escape(guard))}
    end
  end

  defmacro __before_compile__(env) do
    plugs = Module.get_attribute(env.module, :plugs)

    quote do
      defp plugs, do: unquote(Macro.escape(plugs))
    end
  end

  @doc """
  Custom controller factory.
  """
  defmacro __using__(_opts) do
    quote do
      alias GenRouter.Conn
      import GenRouter.Conn
      import GenRouter.Controller

      Module.register_attribute(__MODULE__, :plugs, accumulate: true)

      @before_compile GenRouter.Controller

      @doc """
      Do matching to a proper controller action.
      """
      @spec do_action(atom(), Conn.t, Keyword.t) :: Conn.t
      def do_action(action, conn, opts \\ []) do
        conn =
          Enum.reduce(plugs(), conn, fn {plug, plug_opts, guards}, conn ->
            guards =
              if is_boolean(guards) do
                guards
              else
                {[guards], _} = Code.eval_quoted(guards, action: action)
                guards
              end
            if guards do
              apply(plug, :call, [conn, plug_opts])
            else
              conn
            end
          end)

        unless conn.halted do
          apply(__MODULE__, action, [conn, opts])
        else
          conn
        end
      end
    end
  end
end
