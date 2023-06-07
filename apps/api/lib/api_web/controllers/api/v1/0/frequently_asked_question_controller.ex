#-------------------------------------------------------------------------------
# Author: Tanbits <dev@tanbits.com>, Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2022 Travellers Connect, inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule ApiWeb.Api.V1_0.FrequentlyAskedQuestionController do
  @moduledoc """
  Manage list of Frequently Asked Questions.
  """

  #============================================================================
  # Uses, Requires, Aliases
  #============================================================================
  import Ecto.Query, warn: false

  use ApiWeb, :controller
  use Filterable.Phoenix.Controller
  use PhoenixSwagger

  alias Data.Context
  alias Data.Schema.FrequentlyAskedQuestion
  alias Data.Context.FrequentlyAskedQuestions

  #============================================================================
  # Controller Actions
  #============================================================================

  #----------------------------------------------------------------------------
  # index\2
  #----------------------------------------------------------------------------
  swagger_path :index do
    get "/v1.0/faqs"
    summary "Get List OF FrequentlyAskedQuestions"
    description "Get List OF FrequentlyAskedQuestions"
    produces "application/json"
    security [%{Bearer: []}]
    parameters do
      page(:query, :integer, "Page no.", required: true)
    end
    response 200, "Ok", Schema.ref(:FrequentlyAskedQuestions)
  end

  @doc """
  Return list of frequently asked questions.
  """
  def index(conn, %{"page" => page}) do
    frequently_asked_questions = FrequentlyAskedQuestions.list(FrequentlyAskedQuestion, page)
    render(conn, "frequently_asked_questions.json", %{frequently_asked_questions: frequently_asked_questions})
  end

  #----------------------------------------------------------------------------
  # show\2
  #----------------------------------------------------------------------------
  swagger_path :show do
    get "/v1.0/faqs/{id}"
    summary "Get Frequently Asked Question By ID"
    description "Get FrequentlyAskedQuestion By ID"
    produces("application/json")
    security([%{Bearer: []}])
    parameters do
      id :path, :string, "id", required: true
    end
    response 200, "Ok", Schema.ref(:FrequentlyAskedQuestions)
  end
  @doc """
  get specific F.A.Q. entry
  """
  def show(conn, %{"id" => id}) do
    case Context.get(FrequentlyAskedQuestion, id) do
      nil -> render(conn, "frequently_asked_question.json", %{error: ["frequently_asked_question does not exist"]})
      %{} = frequently_asked_question -> render(conn, "frequently_asked_question.json", %{frequently_asked_question: frequently_asked_question})
    end
  end

  #----------------------------------------------------------------------------
  # create\2
  #----------------------------------------------------------------------------
  swagger_path :create do
    post "/v1.0/faqs"
    summary "Create New Frequently Asked Question"
    description "Create a new frequently_asked_question"
    produces("application/json")
    security [%{Bearer: []}]
    parameters do
      body :body, Schema.ref(:Create), "Create a new frequently_asked_question from params", required: true
    end
    response 200, "Ok", Schema.ref(:FrequentlyAskedQuestions)
  end
  @doc """
  Create new F.A.Q. entry
  """
  def create(conn, params) do
    case Context.create(FrequentlyAskedQuestion, params) do
      {:ok, frequently_asked_question} -> render(conn, "frequently_asked_question.json", %{frequently_asked_question: FrequentlyAskedQuestions.preload_all(frequently_asked_question)})
      {:error, error} -> render(conn, "frequently_asked_question.json", %{error: error})
    end
  end

  #----------------------------------------------------------------------------
  # update\2
  #----------------------------------------------------------------------------
  swagger_path :update do
    put("/v1.0/faqs/{id}")
    summary("Update Frequently Asked Question")
    description("Update Frequently Asked Question")
    produces("application/json")
    security([%{Bearer: []}])
    parameters do
      id(:path, :string, "Interest ID", required: true)
      body(:body, Schema.ref(:UpdateFrequentlyAskedQuestion), "Update FrequentlyAskedQuestion Params", required: true)
    end
    response(200, "Ok", Schema.ref(:FrequentlyAskedQuestions))
  end
  @doc """
  Update F.A.Q. entry
  """
  def update(conn, %{"id" => id} = params) do
    with %FrequentlyAskedQuestion{} = frequently_asked_question <- Context.get(FrequentlyAskedQuestion, id),
         {:ok, %FrequentlyAskedQuestion{} = frequently_asked_question} <- Context.update(FrequentlyAskedQuestion, frequently_asked_question, params) do
      render(conn, "frequently_asked_question.json", %{frequently_asked_question: FrequentlyAskedQuestions.preload_all(frequently_asked_question)})
    else
      nil -> render(conn, "frequently_asked_question.json", %{error: ["Frequently Asked Question not found"]})
      {:error, error} -> render(conn, "frequently_asked_question.json", %{error: error})
    end
  end

  #----------------------------------------------------------------------------
  # delete\2
  #----------------------------------------------------------------------------
  swagger_path :delete do
    PhoenixSwagger.Path.delete "/v1.0/faqs/{id}"
    summary "Delete Frequently Asked Question"
    description "Delete Frequently Asked Question"
    produces "application/json"
    security [%{Bearer: []}]
    parameters do
      id :path, :string, "Frequently Asked Question ID", required: true
    end
    response 200, "Ok", Schema.ref(:FrequentlyAskedQuestions)
  end
  def delete(conn, %{"id" => id} = _params) do
    with %FrequentlyAskedQuestion{} = frequently_asked_question <- Context.get(FrequentlyAskedQuestion, id),
         {:ok, %FrequentlyAskedQuestion{} = frequently_asked_question} <- Context.delete(frequently_asked_question) do
      render(conn, "frequently_asked_question.json", %{frequently_asked_question: FrequentlyAskedQuestions.preload_all(frequently_asked_question)})
    else
      nil -> render(conn, "frequently_asked_question.json", %{error: ["Frequently Asked Question not found"]})
      {:error, error} -> render(conn, "frequently_asked_question.json", %{error: error})
    end
  end

  #========================================================================
  # Swagger Definition
  #========================================================================
  @doc """
  Swagger MetaData.
  """
  def swagger_definitions do
    %{
      FrequentlyAskedQuestions: swagger_schema do
                                  title "Frequently Asked Questions"
                                  description "Frequently Asked Questions"
                                  properties do

                                  end
                                  example [
                                    %{
                                      id: "3df94ca6-efed-4212-a45b-0c55fdcdfb0f",
                                      question: "How are we?",
                                      answer: "we connect people",
                                      image_name: "",
                                      category: "about us",
                                    }
                                  ]
                                end,
      Create: swagger_schema do
                title "Create New Frequently Asked Question"
                description "Create a Frequently Asked Question"
                properties do
                  id :string, "Frequently Asked Question ID"
                  question :string, "Question"
                  answer :string, "Answer"
                  category :string, "category"
                end
                example %{
                  question: "How are we?",
                  answer: "we connect people",
                  image_name: "",
                  category: "about us",
                }
              end,
      UpdateFrequentlyAskedQuestion: swagger_schema do
                                       title "Update Frequently Asked Question"
                                       description "Update Frequently Asked Question"
                                       properties do
                                         id :string, "Frequently Asked Question ID"
                                         question :string, "Question"
                                         answer :string, "Answer"
                                         category :string, "category"
                                       end
                                       example %{
                                         id: "3df94ca6-efed-4212-a45b-0c55fdcdfb0f",
                                         question: "How are we?",
                                         answer: "we connect people",
                                         image_name: "",
                                         category: "about us",
                                       }
                                     end,
    }
  end
end
