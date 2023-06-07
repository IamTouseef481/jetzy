#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.TanbitsResolution.Source.Enum do
  use Noizu.DomainObject
  @vsn 1.0
  @nmid_index 298
  @sref "mssql-source"
  @persistence_layer :mnesia
  @persistence_layer {:ecto, cascade?: true}
  defmodule Entity do
    @universal_identifier false
    @universal_lookup false
    @auto_generate false
    @generate_reference_type :enum_ref
    @enum_list :callback
    Noizu.DomainObject.noizu_entity do
      identifier :integer
      public_field :table_name
      public_field :ecto_name
      public_field :description, nil, Jetzy.VersionedString.TypeHandler
      public_field :time_stamp, nil, Noizu.DomainObject.TimeStamp.Second.TypeHandler
    end
  end

  defmodule Repo do
    Noizu.DomainObject.noizu_repo do

    end
  end


  def description(_enum), do: "not supported"


  def atom_to_enum() do
    Jetzy.DomainObject.Schema.__tanbits_source_atom_to_enum__()
  end
  def atom_to_enum(k), do: atom_to_enum()[k]

  def enum_to_atom() do
    Jetzy.DomainObject.Schema.__tanbits_source_enum_to_atom__()
  end
  def enum_to_atom(k), do: enum_to_atom()[k]

  def json_to_atom() do
    Jetzy.DomainObject.Schema.__tanbits_source_json_to_atom__()
  end
  def json_to_atom(k), do: json_to_atom()[k]

end
