#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp All rights reserved.
#-------------------------------------------------------------------------------

defmodule Mix.Tasks.Sphinx do
  use Mix.Task

  @indexes %{
    "users" => Jetzy.User.Entity,
    "posts" => Jetzy.Post.Entity.Index,
    "comments" => Jetzy.Comment.Entity.Index,
  }

  def run(["indexes"]) do
    IO.puts "----- Available Indexes -----"
    Enum.map(@indexes, fn({k,v}) -> IO.puts " #{k} - #{v}" end)
    IO.puts ""
  end

  def run(["generate", "primary", index]) do
    IO.puts "generate primary"
    if provider = @indexes[index] do
      IO.puts "For #{provider}"
    end
  end

  def run(["generate", "delta", _index]) do
    IO.puts "generate delta"
  end

  def run(_) do
    IO.puts "Usage: mix generate [primary|delta] $index"
    IO.puts "Usage: mix help indexes"
  end

end