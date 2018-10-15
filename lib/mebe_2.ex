defmodule Mebe2 do
  @moduledoc """
  Documentation for Mebe2.
  """

  @conf_datatypes %{
    multi_author_mode: :bool,
    use_default_author: :bool,
    force_read_more: :bool,
    enable_feeds: :bool,
    feeds_full_content: :bool,
    posts_per_page: :int,
    posts_in_feed: :int,
    disqus_comments: :bool,
    page_commenting: :bool,
    port: :int,
    host_port: :int
  }

  @doc """
  Get a configuration setting.

  Gets setting from env vars (same name as setting, but with ALL_CAPS), and uses
  Application.get_env as backup. If setting has a datatype conversion defined above, that will
  be used to map the return datatype. Otherwise return value will be string (if from env var) or
  any() (if from config file).
  """
  @spec get_conf(atom()) :: any()
  def get_conf(key) do
    val =
      case key |> Atom.to_string() |> String.upcase() |> System.get_env() do
        nil -> Application.get_env(:mebe_2, key)
        val -> val
      end

    case Map.get(@conf_datatypes, key) do
      nil ->
        val

      atom ->
        fun = "get_#{Atom.to_string(atom)}!" |> String.to_atom()
        apply(__MODULE__, fun, [val])
    end
  end

  @doc """
  Get boolean from env value, strings ("true", "false") or booleans are accepted as, others will
  raise.
  """
  @spec get_bool!(atom() | String.t()) :: boolean()
  def get_bool!(val) when is_boolean(val), do: val
  def get_bool!("true"), do: true
  def get_bool!("false"), do: false
  def get_bool!(val), do: raise("'#{inspect(val)}' is invalid value for boolean.")

  @doc """
  Get integer from env value, integer strings and integers are accepted, others will raise.
  """
  @spec get_int!(integer() | String.t()) :: integer()
  def get_int!(val) when is_integer(val), do: val
  def get_int!(val) when is_binary(val), do: String.to_integer(val)
  def get_int!(val), do: raise("'#{inspect(val)}' is invalid value for integer.")
end
