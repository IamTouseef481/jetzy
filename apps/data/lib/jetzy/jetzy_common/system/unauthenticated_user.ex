#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2020 TravellersConnect, Inc.
#-------------------------------------------------------------------------------

defmodule Jetzy.System.UnauthenticatedUser do
  @type t :: %Jetzy.System.UnauthenticatedUser{ip: String.t | nil}
  defstruct [ip: nil]

  #-----------------------------------------------------------------------------
  # Behaviour Implementation
  #-----------------------------------------------------------------------------
  def ref(ip), do: {:ref, __MODULE__, ip}


  def sref(ip) when is_bitstring(ip), do: "ref.anonymous.[#{ip}]"
  def sref({:ref, __MODULE__, ip}), do: "ref.anonymous.[#{ip}]"

end
