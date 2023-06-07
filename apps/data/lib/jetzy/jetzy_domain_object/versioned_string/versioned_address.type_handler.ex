#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2022 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.VersionedAddress.TypeHandler do
  use Jetzy.VersionedStringBehavior.TypeHandler

  def from_partial(%Jetzy.VersionedAddress.Entity{} = ref, _, _), do: ref
  def from_partial({:ref, Jetzy.VersionedAddress.Entity, _} = ref, _, _), do: ref

  def from_partial!(%Jetzy.VersionedAddress.Entity{} = ref, _, _), do: ref
  def from_partial!({:ref, Jetzy.VersionedAddress.Entity, _} = ref, _, _), do: ref

end
