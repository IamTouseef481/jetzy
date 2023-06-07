#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2021 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.CMS.Article.Image do
  use Noizu.V3.CMS.ArticleType
  @vsn 1.0
  @kind "cms-image"
  @poly_base Jetzy.CMS.Article
  # this is a defect we should be able to rely on the poly base persistence settings but because the ArticleType using macro injects the persistence layer the fallback logic is bypassed.
  @persistence_layer :mnesia
  defmodule Entity do
    @nmid_index 72
    Noizu.V3.CMS.ArticleType.article_entity() do
      @json format: &Jetzy.CMS.Article.Entity.cms_identifier/6
      identifier :compound
      ecto_identifier :uuid # some tweaks will be needed to insure this is populated.

      public_field :title
      public_field :alt
      public_field :resolution
      public_field :image
      public_field :editor
      internal_field :moderation, nil, Jetzy.ModerationDetails.TypeHandler

      internal_field :attributes
      internal_field :article_info
      internal_field :time_stamp, nil, Noizu.DomainObject.TimeStamp.Second.TypeHandler
    end
    def sref_subtype(), do: "image"
  end
end
