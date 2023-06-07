#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2021 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.CMS.Article.Comment do
  use Noizu.V3.CMS.ArticleType
  @vsn 1.0
  @kind "cms-comment"
  @poly_base Jetzy.CMS.Article
  # this is a defect we should be able to rely on the poly base persistence settings but because the ArticleType using macro injects the persistence layer the fallback logic is bypassed.
  @persistence_layer :mnesia
  defmodule Entity do
    @nmid_index 69
    Noizu.V3.CMS.ArticleType.article_entity() do
      @json format: &Jetzy.CMS.Article.Entity.cms_identifier/6
      identifier :compound
      @json_ignore [:mobile, :verbose_mobile]
      ecto_identifier :uuid # some tweaks will be needed to insure this is populated.

      public_field :body

      @json_ignore [:mobile, :verbose_mobile]
      internal_field :attributes

      @json_ignore [:mobile]
      public_field :editor

      @json_ignore [:mobile]
      internal_field :moderation, nil, Jetzy.ModerationDetails.TypeHandler

      internal_field :media, nil, Jetzy.Entity.Image.Repo.TypeHandler # eventually this will need to be a repo that can pull videos, images, documents

      @json_ignore [:mobile, :verbose_mobile]
      internal_field :article_info

      @json_ignore :mobile
      @json_embed {:verbose_mobile, [:created_on, :modified_on]}
      internal_field :time_stamp, nil, Noizu.DomainObject.TimeStamp.Second.TypeHandler
    end
    def sref_subtype(), do: "comment"


    def sync(existing, update, context, options \\ nil)
    def sync(nil, update, _context, _options) do
      update
    end
    def sync(existing, update, context, _options) do
      existing = Noizu.ERP.entity(existing)
      directive = cond do
                    !existing -> :update
                    existing.body.markdown != update.body -> :merge
                    existing.editor != update.editor -> :merge
                    :else -> :existing
                  end
      case directive do
        :update -> update
        :existing -> existing
        :merge ->
          # @todo - media
          %__MODULE__{
            existing |
            body: Noizu.V3.CMS.MarkdownField.new(update.body),
            editor: update.editor,
            time_stamp: update[:time_stamp] || existing.time_stamp
          }
          |> Noizu.V3.CMS.Article.CMS.new_revision(context)
      end
    end


    def sync!(existing, update, context, options \\ nil)
    def sync!(nil, update, _context, _options) do
      update
    end
    def sync!(existing, update, context, _options) do
      existing = Noizu.ERP.entity!(existing)
      directive = cond do
                    !existing -> :update
                    existing.body.markdown != update.body -> :merge
                    existing.editor != update.editor -> :merge
                    :else -> :existing
                  end
      case directive do
        :update -> update
        :existing -> existing
        :merge ->
          # @todo - media
          %__MODULE__{
            existing |
            body: Noizu.V3.CMS.MarkdownField.new(update.body),
            editor: update.editor,
            time_stamp: update[:time_stamp] || existing.time_stamp
          }
          |> Noizu.V3.CMS.Article.CMS.new_revision!(context)
      end
    end


  end


end
