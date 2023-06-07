#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Sphinx.Index do
  use Noizu.DomainObject
  @vsn 1.0
  @sref "sphinx-index"
  @persistence_layer :mnesia
  @persistence_layer {:ecto, cascade?: true}
  defmodule Entity do
    @nmid_index 115
    Noizu.DomainObject.noizu_entity do
      identifier :integer

      @json {:*, :expand}
      @json_embed {:user_clients, [{:title, as: :name}]}
      @json_embed {:verbose_mobile, [{:title, as: :name}, {:body, as: :description}, {:editor, sref: true}, :revision]}
      public_field :description, nil, type: Jetzy.VersionedString.TypeHandler

      public_field :elixir_class

      public_field :time_stamp, nil, Noizu.DomainObject.TimeStamp.Second.TypeHandler
    end
  end

  defmodule Repo do
    Noizu.DomainObject.noizu_repo do

    end
  end
end
