#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2021 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.CMS.Article do
  use Noizu.V3.CMS.ArticleType
  @vsn 1.0
  @sref "cms"
  @kind "cms-article"
  @poly_support [
    Elixir.Jetzy.CMS.Article,
    Elixir.Jetzy.CMS.Article.Comment,
    Elixir.Jetzy.CMS.Article.Detail,
    Elixir.Jetzy.CMS.Article.File,
    Elixir.Jetzy.CMS.Article.Image,
    Elixir.Jetzy.CMS.Article.Post
  ]
  @poly_base Jetzy.CMS.Article
  @persistence_layer :mnesia
  defmodule Entity do
    @nmid_index 74
    Noizu.V3.CMS.ArticleType.article_entity() do
      @json format: &Jetzy.CMS.Article.Entity.cms_identifier/6
      identifier :compound
      @json_ignore [:mobile, :verbose_mobile]
      ecto_identifier :uuid # unique per version-revision

      public_field :title
      public_field :body

      @json_ignore [:mobile]
      public_field :editor

      @json_ignore [:mobile, :verbose_mobile]
      internal_field :attributes

      @json_ignore [:mobile]
      internal_field :moderation, nil, Jetzy.ModerationDetails.TypeHandler

      @json_ignore [:mobile, :verbose_mobile]
      internal_field :article_info

      @index true
      @json_ignore :mobile
      @json_embed {:verbose_mobile, [:created_on, :modified_on]}
      internal_field :time_stamp, nil, Noizu.DomainObject.TimeStamp.Second.TypeHandler
    end


    def cms_identifier(_json_format, as, value, _settings, _context, _options) do
      {:ok, v} = __id_to_string__(value)
      {as, String.slice(v, 1..-2)}
    end


    def sref_subtype(), do: "article"

  end

  defmodule Repo do
    Noizu.V3.CMS.ArticleType.article_repo() do
    end




  end

  defmodule CMS do
    Noizu.V3.CMS.ArticleType.article_cms_manager(
      tag_table: JetzySchema.Database.CMS.Article.ActiveTag.Table,
      index_table: JetzySchema.Database.CMS.Article.Index.Table,
      version: Jetzy.CMS.Article.Version.Entity,
      revision: Jetzy.CMS.Article.Version.Revision.Entity,
      active_version_table: JetzySchema.Database.CMS.Article.Active.Version.Table,
      active_revision_table: JetzySchema.Database.CMS.Article.Active.Version.Revision.Table
    ) do
    end

    def sref_subtype_module("article"), do: Elixir.Jetzy.CMS.Article.Entity
    def sref_subtype_module("post"), do: Elixir.Jetzy.CMS.Article.Post.Entity
    def sref_subtype_module("file"), do: Elixir.Jetzy.CMS.Article.File.Entity
    def sref_subtype_module("image"), do: Elixir.Jetzy.CMS.Article.Image.Entity
    def sref_subtype_module("comment"), do: Elixir.Jetzy.CMS.Article.Comment.Entity
    def sref_subtype_module("detail"), do: Elixir.Jetzy.CMS.Article.Detail.Entity
  end

end
