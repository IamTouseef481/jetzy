#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2019 JetzyApp All rights reserved.
#-------------------------------------------------------------------------------

defmodule JetzySchema.Mnesia.Changesets.CoreTest do
  use Noizu.MnesiaVersioning.SchemaBehaviour
  # alias Noizu.MnesiaVersioning.ChangeSet
  use Amnesia
  use JetzySchema.Database
  #-----------------------------------------------------------------------------
  # ChangeSets
  #-----------------------------------------------------------------------------

  def change_sets do
    [
    ]
  end
end
