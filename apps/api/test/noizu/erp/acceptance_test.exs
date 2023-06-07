defmodule Noizu.ERP.AcceptanceTest do
  use ApiWeb.Api.V1_0.ConnCase, async: true

  @user_guid "a711bf85-963f-42ed-9728-c2047d5694fb"
  @user_ref {:ref, Data.Schema.User, @user_guid}

  @tag :acceptance
  test "Noizu.ERP.ref(entity)" do
    user = Data.Schema.User.entity!(@user_guid)
    assert user != nil
    assert Noizu.ERP.ref(user) == {:ref, Data.Schema.User, @user_guid}
  end

  @tag :acceptance
  test "Noizu.ERP.entity(entity)" do
    user = Data.Schema.User.entity!(@user_guid)
    assert user != nil
    assert Noizu.ERP.entity(user) == user
  end

  @tag :acceptance
  test "Noizu.ERP.sref(entity)" do
    user = Data.Schema.User.entity!(@user_guid)
    assert user != nil
    assert Noizu.ERP.sref(user) == "ref.t-user.#{@user_guid}"
  end

  @tag :acceptance
  test "Noizu.ERP.id(entity)" do
    user = Data.Schema.User.entity!(@user_guid)
    assert user != nil
    assert Noizu.ERP.id(user) == @user_guid
  end

  @tag :acceptance
  test "Noizu.ERP.ref(ref)" do
    assert Noizu.ERP.ref(@user_ref) == {:ref, Data.Schema.User, @user_guid}
  end

  @tag :acceptance
  test "Noizu.ERP.entity(ref)" do
    user = Data.Schema.User.entity!(@user_guid)
    assert user != nil
    assert Noizu.ERP.entity(@user_ref) == user
  end

  @tag :acceptance
  test "Noizu.ERP.sref(ref)" do
    assert Noizu.ERP.sref(@user_ref) == "ref.t-user.#{@user_guid}"
  end

  @tag :acceptance
  test "Noizu.ERP.id(ref)" do
    assert Noizu.ERP.id(@user_ref) == @user_guid
  end


end