#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.User.Notification.Type do
  use Noizu.DomainObject
  @vsn 1.0
  @sref "user-notification-type"
  @persistence_layer :mnesia
  @persistence_layer {:ecto, cascade?: true}
  #@index {{:inline, :sphinx}, [type: :real_time, pii: :level_2, default: [{Jetzy.Sphinx.LocationIndex, [anonymize: false]}]]}
  # Pending Implementation: @index {Jetzy.Admin.Index, pii: :level_0, default: [{Jetzy.Sphinx.LocationIndex, [anonymize: false]}]}

  @ecto_type :integer
  @default_value :unknown
  @enum_list [
    unknown: 0,
    friend_request_sent: 1,
    friend_request_accepted: 2,
    post_like: 3,
    post_comment: 4,
    reply: 5,
    referral_complete: 6,
    tagged_in_post: 7,
    tagged_in_comment: 8,
    message_received: 9,
    post_local_user: 10,
    private_group_invitation: 11,
    private_group_request: 12,

  ]

  defmodule Entity do
    @nmid_index 338
    @auto_generate false
    @universal_identifier false
    @nmid_bare true
    Noizu.DomainObject.noizu_entity do
      @meta {:enum_entity, true}
      identifier :atom
      public_field :description, nil, Jetzy.VersionedString.TypeHandler
      public_field :template, nil, Jetzy.VersionedString.TypeHandler
      public_field :time_stamp, nil, Noizu.DomainObject.TimeStamp.Second.TypeHandler
    end

    def ecto_identifier(entity) do
      cond do
        ref = Noizu.ERP.ref(entity) ->
          atom = Noizu.ERP.id(ref)
          cond do
            is_integer(atom) -> atom
            :else -> __enum__()[:type].atom_to_enum(atom)
          end
        :else -> nil
      end
    end

    #===-------
    # has_permission?
    #===-------
    def has_permission?(_entity, _permission, %Noizu.ElixirCore.CallingContext{}), do: true
    def has_permission?(_entity, _permission, %Noizu.ElixirCore.CallingContext{}, _options), do: true

    #===-------
    # has_permission!
    #===-------
    def has_permission!(_entity, _permission, %Noizu.ElixirCore.CallingContext{}), do: true
    def has_permission!(_entity, _permission, %Noizu.ElixirCore.CallingContext{}, _options), do: true


  end

  defmodule Repo do
    require Logger
    @legacy_map %{
      0 => :unknown,
      1 => :post_comment,
      2 => :reply,
      3 => :post_like,
      4 => :friend_request_sent,
      5 => :message_received,
      6 => :post_local_user,
      7 => :tagged_in_post,
      8 => :private_group_invitation,
      9 => :tagged_in_comment,
      10 => :friend_request_accepted,
      11 => :private_group_request
    }

    Noizu.DomainObject.noizu_repo do
    end


    def legacy_enum_to_atom(enum) do
      @legacy_map[enum]
    end

    def extract_type(message, context, options) do
      cond do
        String.match?(message, ~r/^(.*) sent you a friend request\.$/) -> :friend_request_sent
        String.match?(message, ~r/^(.*) accepted your friend request\.$/) -> :friend_request_accepted
        String.match?(message, ~r/^(.*) liked your Post\.$/) -> :post_like
        String.match?(message, ~r/^(.*) commented on your Post\.$/) -> :post_comment
        String.match?(message, ~r/^(.*) replied on your comment\.$/) -> :reply
        String.match?(message, ~r/^Your referred friend (.*) is now on jetzy$/) -> :referral_complete
        String.match?(message, ~r/^Your referred friend (.*) is now on Jetzy. You both will get 100 bonus points.$/) -> :referral_complete
        String.match?(message, ~r/^You have been tagged in a post by (.*)$/) -> :tagged_in_post
        :else ->
          Logger.error "UNSUPPORTED #{inspect message}"
      end
    end

    #===-------
    # has_permission?
    #===-------
    def has_permission?(_, %Noizu.ElixirCore.CallingContext{}), do: true
    def has_permission?(_, %Noizu.ElixirCore.CallingContext{}, _options), do: true
    def has_permission?(_repo, _permission, %Noizu.ElixirCore.CallingContext{}), do: true
    def has_permission?(_repo, _permission, %Noizu.ElixirCore.CallingContext{}, _options), do: true

    #===-------
    # has_permission!
    #===-------
    def has_permission!(_, %Noizu.ElixirCore.CallingContext{}), do: true
    def has_permission!(_, %Noizu.ElixirCore.CallingContext{}, _options), do: true
    def has_permission!(_repo, _permission, %Noizu.ElixirCore.CallingContext{}), do: true
    def has_permission!(_repo, _permission, %Noizu.ElixirCore.CallingContext{}, _options), do: true

  end
end
