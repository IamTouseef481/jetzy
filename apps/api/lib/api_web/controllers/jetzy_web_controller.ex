#-------------------------------------------------------------------------------
# Author: Tanbits <dev@tanbits.com>, Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2022 Travellers Connect, inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule ApiWeb.JetzyWebController do
  @moduledoc """
  Manage Email Verification Flow.
  """

  #============================================================================
  # Uses, Requires, Aliases
  #============================================================================
  use ApiWeb, :controller

  #  alias Data.Context
  #  alias Data.Schema.User







  #============================================================================
  # Controller Actions
  #============================================================================

  def home(conn, params) do
    render(conn, "home.html", %{})
  end
  def download(conn, params) do
    render(conn, "download_app.html", %{})
  end
  def harvard_wood(conn, params) do
    render(conn, "harvard_wood.html", %{})
  end
  def faq(conn, params) do
    render(conn, "jetzy_app_faq.html", %{})
  end
  def faq2(conn, params) do
    render(conn, "jetzy_app_faq_2.html", %{})
  end
  def feedback(conn, params) do
    render(conn, "jetzy_app_feedback.html", %{})
  end
  def terms(conn, params) do
    render(conn, "termsofuse.html", %{})
  end
  def privacy(conn, params) do
    render(conn, "privacy.html", %{})
  end
  def redirect_link(conn, params) do
    render(conn, "redirect_link.html", %{})
  end
  def shout_outs(conn, params) do
    render(conn, "shout_outs.html", %{})
  end
  def termsofuse(conn, params) do
    render(conn, "terms_of_use.html", %{})
  end
  def career(conn, params) do
    render(conn, "jetzy_careers.html", %{})
  end
  def libraries(conn, params) do
    render(conn, "libraries.html", %{})
  end
  def mtrek(conn, params) do
    render(conn, "mtrek.html", %{})
  end

  def select(conn, params) do
    render(conn, "select.html", %{})
  end

end
