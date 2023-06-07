#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.User.Location do
  use Noizu.DomainObject
  @vsn 1.0
  @sref "user-location"
  @derive Noizu.EctoEntity.Protocol
  @persistence_layer :mnesia
  #@persistence_layer :ecto
  defmodule Entity do
    @nmid_index 122
    @universal_identifier false
    @generate_identifier false
    Noizu.DomainObject.noizu_entity do
      identifier :ref # User
      @pii :level_1
      restricted_field :current
      restricted_field :last_reported_position # used for map tracking etc. when we only wish to frequently update position but don't need to constantly register as though user has entered a new location.
      restricted_field :last_reported_position_updated_on # time
      public_field :public
      public_field :recent #, nil, [type: Jetzy.User.Location.History.Repo.TypeHandler, retention: 15]
    end

    # Hack
    def ecto_entity?(), do: true
    def supported?(_), do: true
    def source(_), do: __MODULE__
    def ecto_identifier({:ref, __MODULE__, id}), do: id
    def ecto_identifier(%__MODULE__{} = this), do: this.identifier


    #    defp convert_units(threshold, units \\ :meters)
    #    defp convert_units(threshold, :meters) do
    #      case threshold do
    #        {:meters, v} -> v
    #        {:kilometers, v} -> v / 1000
    #        {:miles, v} -> v * 1609.34
    #        {:feet, v} -> v / 0.3048
    #      end
    #    end
    
    def register_location_change?(_this, _report, _threshold \\ {:meters, 750}) do
      {:replace, :current}
      #      current = Noizu.ERP.entity!(this.current)
      #      cond do
      #        !current -> {:update, :current}
      #        current.visibility != report.visibility ->
      #          cond do
      #            current.visibility != :public ->
      #              public = Noizu.ERP.entity!(this.public)
      #              cond do
      #                !public -> {:update, :current}
      #                convert_units(Jetzy.GeoLocation.approximate_metric_distance(public.geo, report.geo)) >= convert_units(threshold) -> {:update, :current}
      #                :else -> {:update, {:revert, :public}}
      #              end
      #            :else -> {:update, {:current}}
      #          end
      #        convert_units(Jetzy.GeoLocation.approximate_metric_distance(current.geo, report.geo)) >= convert_units(threshold) -> {:update, :current}
      #        report.tagged -> {:update, :current}
      #        report.check_in -> {:update, :current}
      #        :else -> false
      #      end
    end
  end
  
  defmodule Repo do
    Noizu.DomainObject.noizu_repo do
    end
  end
end
