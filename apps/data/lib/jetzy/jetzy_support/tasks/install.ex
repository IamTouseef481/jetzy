#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2019 JetzyApp All rights reserved.
#-------------------------------------------------------------------------------

defmodule Mix.Tasks.Install do
  use Noizu.MnesiaVersioning.Tasks.Install

  def run() do
    IO.puts "Run MnesiaVersioning.Install"
    run([])
    Amnesia.start
  end

  def rebuild() do
    IO.puts "Run MnesiaVersioning.Rebuild"
    rebuild([])
    Amnesia.start
  end

  def rebuild(["confirm_rebuild_production"]), do: rebuild(:confirm_rebuild_production)
  def rebuild(:confirm_rebuild_production) do
    env = Application.get_env(:noizu_mnesia_versioning, :environment, :prod)
    cond do
      env == :prod -> do_rebuild()
      :else -> throw "rebuild(:confirm_rebuild_production) can not be run on non production scripts. Use rebuild() with passing in the confirm arg"
    end
  end
  def rebuild([]) do
    env = Application.get_env(:noizu_mnesia_versioning, :environment, :prod)
    cond do
      env == :prod -> throw "rebuild\0 can not be run on production as it will wipe the entire database. Use rebuild(:confirm_rebuild_production)"
      :else -> do_rebuild()
    end
  end

  defp do_rebuild() do
    Amnesia.stop()
    Process.sleep(2000)
    Amnesia.Schema.destroy()
    Process.sleep(2000)
    Mix.Tasks.Install.run()
    Process.sleep(2000)
    Amnesia.start()
    Mix.Tasks.Migrate.run()
    Process.sleep(2000)
    Amnesia.start()
  end

end
