#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2021 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.CMS.Article.Version do
  use Noizu.V3.CMS.ArticleType.Versioning
  @vsn 1.0
  @sref "cms-article-version"
  @persistence_layer :mnesia
  @auto_generate false
  defmodule Entity do
    @nmid_index 75
    Noizu.V3.CMS.ArticleType.Versioning.versioning_entity() do
      identifier :uuid
      ecto_identifier :uuid # some tweaks will be needed to insure this is populated.
      internal_field :article
      internal_field :parent
      internal_field :editor
      internal_field :status
      internal_field :time_stamp, nil, Noizu.DomainObject.TimeStamp.Second.TypeHandler
    end



    def overwrite_field(:time_stamp = field, source, current, _context, options) do
      cond do
        is_map(source) && Map.has_key?(source, field) -> Map.get(source, field)
        is_list(source) && Keyword.has_key?(source, field) -> Keyword.get(source, field)
        modified_on = source[:modified_on] ->
          current && %Noizu.DomainObject.TimeStamp.Second{current | modified_on: modified_on} || Noizu.DomainObject.TimeStamp.Second.new(modified_on)
        :else ->
          modified_on = options[:current_time] || DateTime.utc_now()
          current && %Noizu.DomainObject.TimeStamp.Second{current | modified_on: modified_on} || Noizu.DomainObject.TimeStamp.Second.new(modified_on)
      end
    end
    def overwrite_field(field, source, current, _context, _options) do
      cond do
        is_map(source) && Map.has_key?(source, field) -> Map.get(source, field)
        is_list(source) && Keyword.has_key?(source, field) -> Keyword.get(source, field)
        :else -> current
      end
    end

    def update_field(:editor = field, source, current, context, options) do
      source[field] || options[:editor] || current || context.caller
    end
    def update_field(:status = field, source, current, context, options) do
      overwrite_field(field, source, current, context, options)
    end
    def update_field(:time_stamp = field, source, current, _context, options) do
      cond do
        is_map(source) && Map.has_key?(source, field) -> Map.get(source, field)
        is_list(source) && Keyword.has_key?(source, field) -> Keyword.get(source, field)
        modified_on = source[:modified_on] ->
          current && %Noizu.DomainObject.TimeStamp.Second{current | modified_on: modified_on} || Noizu.DomainObject.TimeStamp.Second.new(modified_on)
        :else ->
          modified_on = options[:current_time] || DateTime.utc_now()
          current && %Noizu.DomainObject.TimeStamp.Second{current | modified_on: modified_on} || Noizu.DomainObject.TimeStamp.Second.new(modified_on)
      end
    end
    def update_field(field, source, current, _context, _options) do
      cond do
        current -> current
        is_map(source) && Map.has_key?(source, field) -> Map.get(source, field)
        is_list(source) && Keyword.has_key?(source, field) -> Keyword.get(source, field)
        :else -> nil
      end
    end

    def overwrite!(version, update, context, options), do: overwrite(version, update, context, options)
    def overwrite(version, update, context, options) do
      Enum.reduce(
        Map.from_struct(version),
        version,
        fn ({field, current}, acc) ->
          put_in(acc, [Access.key(field)], overwrite_field(field, update, current, context, options))
        end
      )
    end


    def update!(version, update, context, options), do: update(version, update, context, options)
    def update(version, update, context, options) do
      Enum.reduce(
        Map.from_struct(version),
        version,
        fn ({field, current}, acc) ->
          put_in(acc, [Access.key(field)], update_field(field, update, current, context, options))
        end
      )
    end




  end

  defmodule Repo do
    alias JetzySchema.Database.CMS.Article.VersionSequencer.Table, as: VersionSequencerTable

    Noizu.V3.CMS.ArticleType.Versioning.versioning_repo() do
    end

    def new_version(entity, context, options) do
      article_info = Noizu.V3.CMS.Protocol.article_info(entity, context, options)
      article = article_info.article
      #current_version = article_info.version
      version_path = next_version_path(article, article_info.version, context, options)
      version_identifier = {article, version_path}
      %Jetzy.CMS.Article.Version.Entity{
        identifier: version_identifier,
        article: article,
        parent: article_info.version,
        editor: article_info.editor,
        status: article_info.status,
        time_stamp: article_info.time_stamp,
      }
    end

    def new_version!(entity, context, options) do
      article_info = Noizu.V3.CMS.Protocol.article_info!(entity, context, options)
      article = article_info.article
      #current_version = article_info.version
      version_path = next_version_path!(article, article_info.version, context, options)
      version_identifier = {article, version_path}
      %Jetzy.CMS.Article.Version.Entity{
        identifier: version_identifier,
        article: article,
        parent: article_info.version,
        editor: article_info.editor,
        status: article_info.status,
        time_stamp: article_info.time_stamp,
      }
    end

    def version_sequencer(key, _context, _options) do
      case VersionSequencerTable.read(key) do
        v = %{__struct__: VersionSequencerTable} ->
          %VersionSequencerTable{v | sequence: v.sequence + 1}
          |> VersionSequencerTable.write()
          v.sequence + 1
        nil ->
          %{__struct__: VersionSequencerTable, identifier: key, sequence: 1}
          |> VersionSequencerTable.write()
          1
      end
    end

    def version_sequencer!(key, _context, _options) do
      case VersionSequencerTable.read!(key) do
        v = %{__struct__: VersionSequencerTable} ->
          %VersionSequencerTable{v | sequence: v.sequence + 1}
          |> VersionSequencerTable.write!()
          v.sequence + 1
        nil ->
          %{__struct__: VersionSequencerTable, identifier: key, sequence: 1}
          |> VersionSequencerTable.write!()
          1
      end
    end

    def next_version_path(article, version, context, options) do
      cond do
        version == nil -> {version_sequencer({article, {}}, context, options)}
        :else ->
          {:ref, _, {_article, path}} = version
          List.to_tuple(Tuple.to_list(path) ++ [version_sequencer({article, path}, context, options)])
      end
    end

    def next_version_path!(article, version, context, options) do
      cond do
        version == nil -> {version_sequencer!({article, {}}, context, options)}
        :else ->
          {:ref, _, {_article, path}} = version
          List.to_tuple(Tuple.to_list(path) ++ [version_sequencer!({article, path}, context, options)])
      end
    end



  end

end
