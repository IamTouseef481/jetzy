#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.User.Firebase.Lookup do
  use Noizu.DomainObject
  @vsn 1.0
  @sref "user-lku-firebase"
  @persistence_layer :mnesia
  @persistence_layer {:ecto, cascade?: true}
  @persistence_layer {:redis, cascade?: true}
  defmodule Entity do
    @nmid_index 119
    @universal_identifier true
    Noizu.DomainObject.noizu_entity do
      identifier :integer

      @required {:ref, Jetzy.User.Entity}
      @pii :level_0
      restricted_field :user

      @pii :level_0
      @required true
      restricted_field :firebase

      @enum Jetzy.Status
      @required true
      restricted_field :status
    end
  end

  defmodule Repo do
    #import Ecto.Query, only: [from: 2]
    Noizu.DomainObject.noizu_repo do

    end
  end

end
