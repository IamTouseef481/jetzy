#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------
defmodule Jetzy.User.Authentication.Setting do
  use Noizu.DomainObject
  @vsn 1.0
  @sref "auth-setting"
  @persistence_layer :mnesia
  @persistence_layer :ecto
  #@permissions [{[:edit, :view], :user}, {[:view,:index], :restricted}]
  defmodule Entity do
    @nmid_index 117
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
      restricted_field :weight

      @pii :level_2
      restricted_field :description, nil, Jetzy.UserVersionedString.TypeHandler
      @pii :level_2
      restricted_field :status
      @pii :level_2
      restricted_field :setting

      @index true
      public_field :time_stamp, nil, Noizu.DomainObject.TimeStamp.Second.TypeHandler
    end


  end

  defmodule Repo do
    #import Ecto.Query, only: [from: 2]

    Noizu.DomainObject.noizu_repo do
    end

  end

end
