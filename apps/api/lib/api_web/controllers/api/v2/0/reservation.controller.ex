if Application.get_env(:api, :tanbits_shim)[:include_vnext] do

defmodule JetzyApi.V2_0.Reservation.Controller do
  import JetzyWeb.Helpers
  use JetzyApi, :controller
  use PhoenixSwagger

  #---------------------------------------
  # def index/2
  #---------------------------------------
  swagger_path :index do
    PhoenixSwagger.Path.get "/v2.0/reservations"
    summary "..."
    description "..."
    produces "application/json"
    parameters do
    end
    security [%{Bearer: []}]
    response 200, "Ok", Schema.ref(:JetzyReservationList)
  end
  def list_reservations(conn, _params) do
    context = Noizu.ElixirCore.CallingContext.system()
    api_response(conn, %{results: []}, context, nil)
  end

  #---------------------------------------
  # def make_reservation/2
  #---------------------------------------
  swagger_path :make_reservation do
    PhoenixSwagger.Path.post "/v2.0/reservations"
    summary "..."
    description "..."
    produces "application/json"
    parameters do
    end
    security [%{Bearer: []}]
    response 200, "Ok", Schema.ref(:JetzyReservation)
  end
  def make_reservation(conn, _params) do
    context = Noizu.ElixirCore.CallingContext.system()
    api_response(conn, %{outcome: true}, context, nil)
  end

  #---------------------------------------
  # def get_reservation/2
  #---------------------------------------
  swagger_path :get_reservation do
    PhoenixSwagger.Path.get "/v2.0/reservations"
    summary "..."
    description "..."
    produces "application/json"
    parameters do
    end
    security [%{Bearer: []}]
    response 200, "Ok", Schema.ref(:JetzyReservation)
  end
  def get_reservation(conn, _params) do
    context = Noizu.ElixirCore.CallingContext.system()
    api_response(conn, %{outcome: true}, context, nil)
  end

  #---------------------------------------
  # def cancel_reservation/2
  #---------------------------------------
  swagger_path :cancel_reservation do
    PhoenixSwagger.Path.put "/v2.0/reservations/cancel"
    summary "..."
    description "..."
    produces "application/json"
    parameters do
    end
    security [%{Bearer: []}]
    response 200, "Ok", Schema.ref(:JetzyReservation)
  end
  def cancel_reservation(conn, _params) do
    context = Noizu.ElixirCore.CallingContext.system()
    api_response(conn, %{outcome: true}, context, nil)
  end

  #---------------------------------------
  # def modify_reservation/2
  #---------------------------------------
  swagger_path :modify_reservation do
    PhoenixSwagger.Path.put "/v2.0/reservations/{reservation}/modify"
    summary "..."
    description "..."
    produces "application/json"
    parameters do
    end
    security [%{Bearer: []}]
    response 200, "Ok", Schema.ref(:JetzyReservation)
  end
  def modify_reservation(conn, _params) do
    context = Noizu.ElixirCore.CallingContext.system()
    api_response(conn, %{outcome: true}, context, nil)
  end


  #========================================================================
  # Swagger Definition
  #========================================================================
  @doc """
  Swagger MetaData.
  """
  def swagger_definitions do
    %{
      JetzyReservation: swagger_schema do
                     title "Jetzy Reservation"
                     description "Jetzy Reservation"
                     example(
                       %{
                         identifier: 1,
                       })
                   end,
      JetzyReservationList: swagger_schema do
                         title "Jetzy Reservation List"
                         description "Jetzy Reservation List"
                         example ([
                                    %{
                                      identifier: 1,
                                    }
                                  ])
                       end

    }
  end
end

end