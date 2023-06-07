#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2022 Travellers Connect, Inc. All rights reserved.
#-------------------------------------------------------------------------------
defmodule Jetzy.Module.Athena do
  require Logger

  @doc """
  Proof of concept to show how Module.Telemetry can forward analytic events to multiple systems. We could alternatively implement custom telemetry handlers using ExoMeter or :telemetry, that then package and push to S3 for Athena.
  """
  def emit(event, _payload) do
    Logger.info("[Athena] save #{inspect event} to s3")
  end
end