defmodule ApiWeb.Api.V1_0.FrequentlyAskedQuestionView do
  @moduledoc false
  use ApiWeb, :view
  alias ApiWeb.Utils.Common

  def render("frequently_asked_questions.json", %{frequently_asked_questions: frequently_asked_questions}) do
    frequently_asked_question = render_many(frequently_asked_questions, __MODULE__, "frequently_asked_question.json")
    page_data = %{
      total_rows: frequently_asked_questions.total_entries,
      page: frequently_asked_questions.page_number,
      total_pages: frequently_asked_questions.total_pages
    }
    %{data: frequently_asked_question, pagination: page_data}

  end

  def render("frequently_asked_question.json", %{frequently_asked_question: frequently_asked_question}) do
    Common.struct_into_map(frequently_asked_question)
  end

  def render("frequently_asked_question.json", %{error: error}) do
    %{errors: error}
  end
end
