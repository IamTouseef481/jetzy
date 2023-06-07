#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2019 JetzyApp All rights reserved.
#-------------------------------------------------------------------------------

defmodule JetzySchema.Mnesia.SchemaProvider do
  use Amnesia
  @behaviour Noizu.MnesiaVersioning.SchemaBehaviour

  def neighbors() do
    {:ok, nodes} = JetzySchema.Mnesia.TopologyProvider.mnesia_nodes();
    nodes
  end

  #-----------------------------------------------------------------------------
  # ChangeSets
  #-----------------------------------------------------------------------------
  def change_sets do
    # Hack
    # Jetzy.Repo.start_link()
    # End Hack
    Noizu.AdvancedScaffolding.Support.Schema.Core.change_sets() ++
    Noizu.FastGlobal.V3.ChangeSet.change_sets() ++
    Noizu.V3.CMS.ChangeSet.change_sets() ++
    Noizu.EmailService.V3.ChangeSet.change_sets() ++
    Noizu.SmartToken.V3.ChangeSet.change_sets() ++
    JetzySchema.Mnesia.Changesets.PG.change_sets() ++
    JetzySchema.Mnesia.Changesets.Core.change_sets() ++
    JetzySchema.Mnesia.Changesets.CoreTest.change_sets() ++
    JetzySchema.Mnesia.Changesets.Perf.change_sets()
  end

end # End Mix.Task.Migrate
