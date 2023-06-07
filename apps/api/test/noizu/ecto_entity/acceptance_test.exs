defmodule Noizu.EctoEntity.AcceptanceTest do
  use ApiWeb.Api.V1_0.ConnCase, async: true
  @user_guid "a711bf85-963f-42ed-9728-c2047d5694fb"
  @user_ref {:ref, Data.Schema.User, @user_guid}

  @tag :acceptance
  test "ecto_identifier"  do
    user = Data.Schema.User.entity!(@user_guid)
    assert user != nil
    assert Noizu.EctoEntity.Protocol.ecto_identifier(user) == @user_guid
  end

  @tag :acceptance
  test "source"  do
    user = Data.Schema.User.entity!(@user_guid)
    assert user != nil
    assert Noizu.EctoEntity.Protocol.source(user) == user.__struct__
  end

end