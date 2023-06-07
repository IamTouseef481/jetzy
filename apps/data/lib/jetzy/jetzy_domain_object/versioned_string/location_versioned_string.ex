#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.LocationVersionedString do
  use Jetzy.VersionedStringBehavior
  @vsn 1.0
  @sref "v-location-str"

  defmodule Entity do
    @nmid_index 133
    use Jetzy.VersionedStringBehavior.Entity
  end

  defmodule Repo do
    @source_field :location_versioned_string
    use Jetzy.VersionedStringBehavior.Repo
  end

end
