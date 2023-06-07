defmodule ApiWeb.UserControllerTest do
  use ApiWeb.Api.V1_0.ConnCase

  @invalid_login %{
    "password" => "12345",
    "login" => "superadmin+not_real@jetzy.com",
    "installs" => %{
      "fcm_token" => "dfsfads543fdsfdasd",
      "device_token" => "dsadsadsadsa"
    }
  }

  @admin_login %{
    "password" => "12345",
    "login" => "superadmin@jetzy.com",
    "installs" => %{
      "fcm_token" => "dfsfads543fdsfdasd",
      "device_token" => "dsadsadsadsa"
    }
  }

  @tag :acceptance
  test "POST /sign-in (Sign-In)", %{conn: conn} do
    conn = post(conn, "/api/v1.0/sign-in", @admin_login)
    r = json_response(conn, 200)
    assert r["ResponseData"]["firstName"] == "Super"
  end

  @tag :acceptance
  test "POST /sign-in (Sign-In Failure)", %{conn: conn} do
    conn = post(conn, "/api/v1.0/sign-in", @invalid_login)
    json_response(conn, 404)
  end

end