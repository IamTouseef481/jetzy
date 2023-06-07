#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2020 TravellersConnect, Inc.
#-------------------------------------------------------------------------------

defmodule JetzyModule.AccessControlList do
  
  def get_permissions(<<uuid::binary-size(16)>>), do: get_permissions(UUID.binary_to_string!(uuid))
  def get_permissions(user) do
    # todo build permission tree.
    # todo cache.
    roles = SecureX.Context.get_user_roles_by_user_id(user)
    cond do
      "admin" in roles -> %{admin: true, user: true, system: false}
      "user" in roles -> %{user: true, system: false}
      :else -> %{guest:  true, system: false}
    end
  end
end
