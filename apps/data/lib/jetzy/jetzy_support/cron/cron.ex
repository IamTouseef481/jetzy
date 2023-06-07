defmodule Jetzy.Support.Cron do
  use Quantum.Scheduler,
      otp_app: :data
  require Logger

  def legacy_sync() do
    Semaphore.call({:legacy, :sync}, 1, &__MODULE__.perform_legacy_sync/0)
  end

  def perform_legacy_sync() do
    context = Noizu.ElixirCore.CallingContext.admin()
    JetzyModule.LegacyModule.import!(Jetzy.Post, 1, context, [auto: true])
    JetzyModule.LegacyModule.import!(Jetzy.User, 1, context, [auto: true])
  rescue e ->
    Logger.error(Exception.format(:error, e, __STACKTRACE__))
  catch
    :exit, e ->
      Logger.error(Exception.format(:error, e, __STACKTRACE__))
    e ->
      Logger.error(Exception.format(:error, e, __STACKTRACE__))
  end
  
end