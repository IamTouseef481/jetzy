#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.VersionedString.HistoryBehavior do
  defmodule Entity do
    defmacro __using__(options \\ nil) do
      date_time_type = Noizu.DomainObject.DateTime.Millisecond.TypeHandler
      moderation_type = Jetzy.ModerationDetails.TypeHandler
      source = options[:source] || :versioned_string
      quote do
        @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
        @universal_identifier true
        Noizu.DomainObject.noizu_entity do
          identifier :uuid

          @json_ignore [:verbose_mobile, :mobile]
          public_field :editor

          public_field unquote(source)

          @json_ignore [:mobile]
          public_field :revision, 0

          public_field :title, ""
          public_field :body, ""

          @json_ignore [:mobile]
          public_field :modified_on, nil, type: unquote(date_time_type)

          @json_ignore [:mobile]
          internal_field :moderation, nil, type: unquote(moderation_type)
        end


      end
    end
  end

  defmodule Repo do
    defmacro __using__(_options \\ nil) do
      quote do
        Noizu.DomainObject.noizu_repo do

        end

      end
    end
  end

  defmacro __using__(_options \\ nil) do
    quote do
      use Noizu.DomainObject
      @persistence_layer {:mnesia, cascade?: true, cascade_block?: true}
      @persistence_layer {:ecto, cascade?: true, cascade_block?: false}
    end
  end

end
