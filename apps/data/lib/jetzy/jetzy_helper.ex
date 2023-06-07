defmodule Jetzy.Helper do
  
  def get_cached_setting(setting, default \\ %{}) do
    key = :"cs-#{inspect setting}"
    Noizu.FastGlobal.Cluster.get(key,
      fn() ->
        if JetzySchema.Database.Setting.Table.wait(500) == :ok do
          case JetzySchema.Database.Setting.Table.read!(setting) do
            %JetzySchema.Database.Setting.Table{value: v} -> v
            nil -> if is_function(default, 0), do: default.(), else: default
            _ ->
              v = if is_function(default, 0), do: default.(), else: default
              {:fast_global, :no_cache, v}
          end
        else
          v = if is_function(default, 0), do: default.(), else: default
          {:fast_global, :no_cache, v}
        end
      end
    )
  end

  def clear_cached_setting(setting) do
    key = :"cs-#{inspect setting}"
    spawn fn -> Enum.map(Node.list(), &(:rpc.cast(&1, FastGlobal, :delete, [key]))) end
    FastGlobal.delete(key)
  end

  def set_cached_setting(setting, value) do
    key = :"cs-#{inspect setting}"
    %JetzySchema.Database.Setting.Table{
      identifier: setting,
      value: value
    } |> JetzySchema.Database.Setting.Table.write!()
    spawn fn -> Enum.map(Node.list(), &(:rpc.cast(&1, FastGlobal, :delete, [key]))) end
    FastGlobal.delete(key)
  end




  def sanitize_string(nil), do: nil
  def sanitize_string(string) do
    case :unicode.characters_to_binary(string, :unicode, :unicode) do
      v when is_bitstring(v) -> {:ok, v}
      _ ->
        case Codepagex.from_string(string, :"ISO8859/8859-13", Codepagex.replace_nonexistent(" ")) do
          {:ok, bin, nil} -> Codepagex.to_string(bin, :"ISO8859/8859-13")
          {:ok, bin, _} ->
            case Codepagex.to_string(bin, :"ISO8859/8859-13") do
              {:ok, s} -> {:partial, s}
              error -> error
            end
          error -> error
        end
    end
    rescue _e -> {:error, "Exception Raised"}
    catch
      _e -> {:error, "Exception Raised"}
      :exit, _e -> {:error, "Exception Raised"}
  end

  def get_sanitized_string(string, section, existing, record, context) do
    case Jetzy.Helper.sanitize_string(string) do
      nil -> nil
      {:ok, v} -> String.trim(v)
      {:partial, v} ->
        Jetzy.Import.Error.Entity.new(section, "Import String Partial Error", nil, existing, record)
        |>Jetzy.Import.Error.Repo.create!(context)
        String.trim(v)
      error = {:error, _} ->
        Jetzy.Import.Error.Entity.new(section, "Import String Error", error, existing, record)
        |>Jetzy.Import.Error.Repo.create!(context)
        ""
    end
  end

  def truncate(string, length \\ 10, options \\ nil)
  def truncate(nil, _, _opts), do: nil
  def truncate(string, length, options) when is_bitstring(string) and is_integer(length) and length > 0 do
    excluded_middle = options[:middle]
    fill = case options[:fill] do
             false -> ""
             v when is_bitstring(v) ->
               cond do
                 String.length(v) < length -> v
                 length >= 3 -> "..."
                 :else -> "|"
               end
               String.length(v) < length && v || "..."
             _ ->
               cond do
                 length >= 3 -> "..."
                 :else -> "|"
               end
           end

    cond do
      !string -> string
      String.length(string) <= length -> string
      excluded_middle ->
        cut = length - String.length(fill)
        l = div(cut, 2) + rem(cut, 2)
        r = div(cut, 2)
        (l > 0 && String.slice(string, 0..(l - 1)) || "") <> fill <> (r > 0 && String.slice(string, (-r)..-1) || "")
      :else ->
        l = length - String.length(fill)
        (l > 0 && String.slice(string, 0..(l - 1)) || "") <> fill
    end
  end

  def editor(editor, entity, context, options) do
    cond do
      editor -> editor
      options[:owner] -> options[:owner]
      options[:derive_editor] ->
        cond do
          Map.has_key?(entity, :owner) -> entity.owner
          Map.has_key?(entity, :user) -> entity.user
          is_user_ref = apply(Elixir.Jetzy.User.Entity, :ref, [entity]) -> is_user_ref
          :else -> context.caller
        end
      :else -> context.caller
    end
  end


  def user(user, entity, context, options) do
    cond do
      user -> user
      options[:user] -> options[:user]
      options[:owner] -> options[:owner]
      options[:derive_editor] != false ->
        cond do
          Map.has_key?(entity, :owner) -> entity.owner
          Map.has_key?(entity, :user) -> entity.user
          is_user_ref = apply(Elixir.Jetzy.User.Entity, :ref, [entity]) -> is_user_ref
          options[:context_fallback] != false -> context.caller
          :else -> nil
        end
      options[:context_fallback] != false -> context.caller
      :else -> nil
    end
  end

end
