#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2019 JetzyApp All rights reserved.
#-------------------------------------------------------------------------------

defmodule Mix.Tasks.Migrate do
  use Noizu.MnesiaVersioning.Tasks.Migrate

  def rebuild(), do: Mix.Tasks.Install.rebuild()
  def rebuild(arg), do: Mix.Tasks.Install.rebuild(arg)
  def run() do
    IO.puts "Running MnesiaVersioning.Migrate"
    run([])
    Amnesia.start()
  end
  def count(n) when is_integer(n), do: run(["count", "#{n}"])

end
