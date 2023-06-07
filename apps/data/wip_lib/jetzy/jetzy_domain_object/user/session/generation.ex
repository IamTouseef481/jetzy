#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------
defmodule Jetzy.User.Session.Generation do
  use Noizu.DomainObject
  @vsn 1.0
  @sref "session-gen"
  @persistence_layer :mnesia
  #@permissions [{[:edit, :view], :user}, {[:view,:index], :restricted}]
  defmodule Entity do
    @nmid_index 123
    @universal_identifier true
    Noizu.DomainObject.noizu_entity do
      identifier :ref  #  {user, {device} | {credential} | {}} | {credential_provider}}
      public_field :generation
    end
  end

  defmodule Repo do
    #import Ecto.Query, only: [from: 2]

    Noizu.DomainObject.noizu_repo do
    end

  end

end
