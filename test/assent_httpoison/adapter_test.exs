defmodule AssentHTTPoison.AdapterTest do
  use ExUnit.Case, async: true

  alias AssentHTTPoison.Adapter
  alias Assent.HTTPAdapter.HTTPResponse

  import ExUnit.CaptureLog

  doctest Adapter

  test "supports http/1.1 protocol" do
    TestServer.add("/", via: :get)
    opts = [protocols: [:http1]]

    assert {:ok, %HTTPResponse{status: 200, body: "HTTP/1.1"}} =
             Adapter.request(:get, TestServer.url(), nil, [], opts)
  end

  test "handles https requests" do
    TestServer.start(scheme: :https)
    TestServer.add("/", via: :get)
    opts = [ssl: [cacerts: TestServer.x509_suite().cacerts]]

    assert {:ok, %HTTPResponse{status: 200, body: "HTTP/1.1"}} =
             Adapter.request(:get, TestServer.url(), nil, [], opts)
  end

  test "errors when ssl handshake fails" do
    TestServer.start(scheme: :https)
    bad_host_url = TestServer.url(host: "bad-host.localhost")
    opts = [ssl: [cacerts: TestServer.x509_suite().cacerts]]

    assert capture_log(fn ->
             assert {:error, %HTTPoison.Error{reason: {:tls_alert, {:handshake_failure, _}}}} =
                      Adapter.request(:get, bad_host_url, nil, [], opts)
           end) =~ "Handshake Failure"
  end

  test "succeeds when ssl has no verification" do
    TestServer.start(scheme: :https)
    TestServer.add("/", via: :get)
    bad_host_url = TestServer.url(host: "bad-host.localhost")
    opts = [ssl: [cacerts: TestServer.x509_suite().cacerts, verify: :verify_none]]

    assert {:ok, %HTTPResponse{status: 200}} =
             Adapter.request(:get, bad_host_url, nil, [], opts)
  end

  test "errors when host is unreachable" do
    TestServer.start()
    url = TestServer.url()
    TestServer.stop()

    assert {:error, %HTTPoison.Error{reason: :econnrefused}} =
             Adapter.request(:get, url, nil, [], [])
  end

  test "forwards url query" do
    TestServer.add("/get",
      via: :get,
      to: fn conn ->
        assert conn.query_string == "a=1"
        Plug.Conn.send_resp(conn, 200, "")
      end
    )

    assert {:ok, %HTTPResponse{status: 200}} =
             Adapter.request(:get, TestServer.url("/get?a=1"), nil, [], [])
  end

  test "forwards post body" do
    content_type = "application/x-www-form-urlencoded"
    headers = [{"content-type", "application/x-www-form-urlencoded"}]

    TestServer.add("/post",
      via: :post,
      to: fn conn ->
        {:ok, body, conn} = Plug.Conn.read_body(conn, [])
        assert URI.decode_query(body) == %{"a" => "1", "b" => "2"}
        assert Plug.Conn.get_req_header(conn, "content-type") == [content_type]

        Plug.Conn.send_resp(conn, 200, "")
      end
    )

    assert {:ok, %HTTPResponse{status: 200}} =
             Adapter.request(:post, TestServer.url("/post"), "a=1&b=2", headers, [])
  end

  test "forwards empty body when post body is nil" do
    TestServer.add("/post",
      via: :post,
      to: fn conn ->
        assert {:ok, "", conn} = Plug.Conn.read_body(conn, [])
        Plug.Conn.send_resp(conn, 200, "")
      end
    )

    assert {:ok, %HTTPResponse{status: 200}} =
             Adapter.request(:post, TestServer.url("/post"), nil, [], [])
  end
end
