#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2021 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.CMS.Article.Post do
  use Noizu.V3.CMS.ArticleType
  @vsn 1.0
  @kind "cms-post"
  @poly_base Jetzy.CMS.Article
  # this is a defect we should be able to rely on the poly base persistence settings but because the ArticleType using macro injects the persistence layer the fallback logic is bypassed.
  @persistence_layer :mnesia
  defmodule Entity do
    @nmid_index 73
    Noizu.V3.CMS.ArticleType.article_entity() do
      @json format: &Jetzy.CMS.Article.Entity.cms_identifier/6
      identifier :compound
      @json_ignore [:mobile, :verbose_mobile]
      ecto_identifier :uuid # some tweaks will be needed to insure this is populated.

      public_field :title
      public_field :body

      @json_ignore [:mobile]
      public_field :editor

      @json_ignore [:mobile, :verbose_mobile]
      internal_field :attributes

      @json_ignore [:mobile]
      internal_field :moderation, nil, Jetzy.ModerationDetails.TypeHandler

      internal_field :media, nil, Jetzy.Entity.Image.Repo.TypeHandler # eventually this will need to be a repo that can pull vidoes, images, documents

      @json_ignore [:mobile, :verbose_mobile]
      internal_field :article_info

      @json_ignore :mobile
      @json_embed {:verbose_mobile, [:created_on, :modified_on]}
      internal_field :time_stamp, nil, Noizu.DomainObject.TimeStamp.Second.TypeHandler
    end
    def sref_subtype(), do: "post"
  end

end
