#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.User.Credential.TypeHandler do
  use Amnesia
  require  Noizu.DomainObject
  Noizu.DomainObject.noizu_type_handler()

  alias Jetzy.User.Credential.Repo
  alias Jetzy.User.Credential.Entity

  def strip_inspect(field, value, _opts) do
    case value do
      {:import, _} -> {field, :from_mssql}
      _ -> {field, value}
    end
  end



  #----------------------------------
  # prep_credentials
  #----------------------------------
  def prep_credentials(nil, _entity, _context, _options), do: nil
  def prep_credentials(value = %{__struct__: Jetzy.User.Credential.Entity}, entity, context, options) do
    prep_credentials(%Jetzy.User.Credential.Repo{entities: [value]}, entity, context, options)
  end
  def prep_credentials(value = %{__struct__: Jetzy.User.Credential.Repo, entities: credentials}, entity, context, options) when is_list(credentials) do
    options_c = (options[:credentials] || [])
                |> update_in([:derived_user],
                     fn
                       (nil) -> true
                       (p) -> p
                     end)
                |> update_in([:contact_fallback],
                     fn
                       (nil) -> true
                       (p) -> p
                     end)

    updated_credentials = Enum.map(credentials, fn(credential) ->
      updated_credential = %Jetzy.User.Credential.Entity{credential|
        identifier: credential.identifier || Jetzy.User.Credential.Repo.generate_identifier(),
        user: Jetzy.Helper.user(credential.user, entity, context, options_c)
      }
      cond do
        credential.identifier == nil -> Jetzy.User.Credential.Repo.create(updated_credential, context, options)
        compare(credential, updated_credential) != :eq ->
          spawn(fn -> Jetzy.User.Credential.Repo.update(updated_credential, context, options) end)
          updated_credential
        :else -> updated_credential
      end
    end)
    %Jetzy.User.Credential.Repo{value| entities: updated_credentials}
  end
  def prep_credentials(v, _context, _options), do: v

  #--------------------------------------
  # from_partial
  #--------------------------------------
  def from_partial(%{__struct__: Entity, user: nil} = v, _, options) do
    %{v| user: options[:user] || options[:subject]}
  end
  def from_partial(%{__struct__: Entity} = v, _, _), do: v
  def from_partial({:ref, Entity, _} = ref, _, _), do: ref
  def from_partial(_, _, _), do: nil

  #--------------------------------------
  # from_partial!
  #--------------------------------------
  def from_partial!(%{__struct__: Entity, user: nil} = v, _, options) do
    %{v| user: options[:user] || options[:subject]}
  end
  def from_partial!(%{__struct__: Entity} = v, _, _), do: v
  def from_partial!({:ref, Entity, _} = ref, _, _), do: ref
  def from_partial!(_, _, _), do: nil



  #--------------------------------------
  #
  #--------------------------------------
  def pre_create_callback(field, entity, context, options) do
    if x = get_in(entity, [Access.key(field)]) do
      options = update_in(options || [], [Data.Repo], &(put_in(&1||[], [:cascade?], false)))
      options_b = (options || []) |> update_in([:subject], &(&1 || Noizu.ERP.ref(entity)))
      x = case from_partial(x, context, options_b) do
            x = %{identifier: nil} -> Repo.create(x, context, options) |> put_in([Access.key(:__transient__), :persist?], true)
            x -> x
          end
      cond do
        is_struct(x) && get_in(x, [Access.key(:__transient__), :persist?]) -> put_in(entity, [Access.key(:__transient__), field], x)
        :else -> entity
      end |> put_in([Access.key(field)], Noizu.ERP.ref(x))
    else
      entity
    end
  end
  def pre_create_callback!(field, entity, context, options) do
    if x = get_in(entity, [Access.key(field)]) do
      options = update_in(options || [], [Data.Repo], &(put_in(&1||[], [:cascade?], false)))
      options_b = (options || []) |> update_in([:subject], &(&1 || Noizu.ERP.ref(entity)))
      x = case from_partial!(x, context, options_b) do
            x = %{identifier: nil} -> Repo.create!(x, context, options) |> put_in([Access.key(:__transient__), :persist?], true)
            x -> x
          end
      cond do
        is_struct(x) && get_in(x, [Access.key(:__transient__), :persist?]) -> put_in(entity, [Access.key(:__transient__), field], x)
        :else -> entity
      end |> put_in([Access.key(field)], Noizu.ERP.ref(x))
    else
      entity
    end
  end

  def post_create_callback(field, entity, context, options) do
    {x, entity} = pop_in(entity, [Access.key(:__transient__), field])
    cond do
      is_struct(x) && get_in(x, [Access.key(:__transient__), :persist?]) ->
        options = (options || [])
                  |> update_in([Data.Repo], &(put_in(&1||[], [:cascade?], true)))
                  |> put_in([:cascade?], false)
                  |> put_in([:override_identifier], true)
        Repo.create!(x, context, options)
      :else -> :nop
    end
    entity
  end

  def post_create_callback!(field, entity, context, options) do
    {x, entity} = pop_in(entity, [Access.key(:__transient__), field])
    cond do
      is_struct(x) && get_in(x, [Access.key(:__transient__), :persist?]) ->
        options = (options || [])
                  |> update_in([Data.Repo], &(put_in(&1||[], [:cascade?], true)))
                  |> put_in([:cascade?], false)
                  |> put_in([:override_identifier], true)
        Repo.create!(x, context, options)
      :else -> :nop
    end
    entity
  end

  #-------------------------------
  #
  #-------------------------------
  def pre_update_callback(field, entity, context, options) do
    pre_create_callback(field, entity, context, options)
  end

  #-------------------------------
  #
  #-------------------------------
  def pre_update_callback!(field, entity, context, options) do
    pre_create_callback!(field, entity, context, options)
  end

  #-------------------------------
  #
  #-------------------------------
  def post_update_callback(field, entity, context, options) do
    post_create_callback(field, entity, context, options)
  end

  #-------------------------------
  #
  #-------------------------------
  def post_update_callback!(field, entity, context, options) do
    post_create_callback!(field, entity, context, options)
  end


  #----------------------------------
  # compare/3
  #----------------------------------
  def compare(a, b, options \\ nil)
  def compare(a = %{__struct__: Jetzy.User.Credential.Entity}, b = %{__struct__: Jetzy.User.Credential.Entity}, options) do
    cond do
      a.identifier != b.identifier -> :neq
      a.user != b.user -> :neq
      a.status != b.status -> :neq
      a.credential_type != b.credential_type -> :neq
      a.credential_provider != b.credential_provider -> :neq
      a.settings != b.settings -> :neq
      :else -> Noizu.DomainObject.TimeStamp.Second.compare(a.time_stamp, b.time_stamp, options)
    end
  end
  def compare(%{__struct__: Jetzy.User.Credential.Entity}, nil, _options), do: :neq
  def compare(nil, %{__struct__: Jetzy.User.Credential.Entity}, _options), do: :neq
  def compare(nil, nil, _options), do: :eq
end
