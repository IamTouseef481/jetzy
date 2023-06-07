#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.User.Referral.Redemption do
  use Noizu.DomainObject
  @vsn 1.0
  @sref "referral"
  @persistence_layer :mnesia
  @persistence_layer :ecto
  defmodule Entity do
    @nmid_index 128
    @universal_identifier true
    Noizu.DomainObject.noizu_entity do
      identifier :uuid

      public_field :user
      public_field :referred_user
      public_field :user_referral_code
      public_field :entered_referral_on, nil,  Noizu.DomainObject.DateTime.Second.TypeHandler
      public_field :joined_select_on, nil,  Noizu.DomainObject.DateTime.Second.TypeHandler

      public_field :time_stamp, nil, Noizu.DomainObject.TimeStamp.Second.TypeHandler
    end
  end

  defmodule Repo do
    # import Ecto.Query, only: [from: 2]

    Noizu.DomainObject.noizu_repo do

    end

    def by_code(code, _context, _options \\ nil) do
      if ref = Jetzy.User.Referral.Code.Entity.ref(code) do
        JetzySchema.Database.User.Referral.Redemption.Table.match!([user_referral_code: ref])
        |> Amnesia.Selection.values
      else
        []
      end
    end



  end
end
