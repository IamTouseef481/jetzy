#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------
defmodule Jetzy.User.Session do
  use Noizu.DomainObject
  @vsn 1.0
  @sref "user-session"
  @persistence_layer :mnesia
  @persistence_layer :ecto
  #@permissions [{[:edit, :view], :user}, {[:view,:index], :restricted}]
  defmodule Entity do
    @nmid_index 124
    @universal_identifier true
    Noizu.DomainObject.noizu_entity do
      @pii :level_2
      identifier :integer

      @pii :level_2
      restricted_field :user

      @pii :level_2
      restricted_field :device
      @pii :level_2
      restricted_field :credential
      @pii :level_2
      restricted_field :status
      @pii :level_2
      restricted_field :generation

      @pii :level_2
      restricted_field :session_start, nil, Noizu.DomainObject.TimeStamp.Millisecond.TypeHandler
      @pii :level_2
      restricted_field :session_end, nil, Noizu.DomainObject.TimeStamp.Millisecond.TypeHandler
      @pii :level_2
      restricted_field :expire_after, nil, Noizu.DomainObject.TimeStamp.Millisecond.TypeHandler
    end
  end

  defmodule Repo do
    # import Ecto.Query, only: [from: 2]

    Noizu.DomainObject.noizu_repo do
    end



    #-------------------------
    #
    #-------------------------
    def effective_generation(_session) do
      # @todo Max global, user, user.device, user.credential_provider.type
      0
    end

    def by_credential!(credential, _context, _options) do
      if ref = Jetzy.User.Credential.Entity.ref(credential) do
        JetzySchema.Database.User.Session.Table.match!([credential: ref])
        |> Amnesia.Selection.values()
      end
    end

    #-------------------------
    # by_claim!\1
    #-------------------------
    def by_claim!(claims) do
      case claims do
        %{"session" => session_sref, "sref" => user_sref} ->
          session = Jetzy.User.Session.Entity.entity!(session_sref)
          user_ref = Jetzy.User.Entity.ref(user_sref)
          cond do
            !session -> {:error, :session_not_found}
            !session.user -> {:error, :session_incomplete}
            !user_ref -> {:error, :user_not_found}
            session.user == user_ref ->
              effective_generation = effective_generation(session)
              cond do
                session.generation >= effective_generation -> {:ok, session}
                :else ->
                  # todo log out user/end session.
                  {:error, :logged_out}
              end
          end
        %{"user_id" => _firebase_uid} ->
          # @todo restore
          {:error, :firebase_nyi}
        _ ->
          {:error, :unsupported_claim}
      end
    end

    def by_claim(claims), do: by_claim!(claims)
  end

end
