# frozen_string_literal: true

require_relative "test_helper"

class ProxyIntegrationTest < Minitest::Test
  include Helper

  class TestApp
    def call(env)
      case env["REQUEST_METHOD"]
      when "GET"   then [200, { "Content-Type" => "text/html" }, ["Response for GET\n"]]
      when "OTHER" then [600, { "Content-Type" => "text/html" }, ["Response for OTHER\n"]]
      end
    end
  end

  def setup
    setup_test_protocol

    @server_pid = fork do
      Process.setpgrp # To detach from current process group
      ::Rack::Handler::Toycol.run(TestApp.new, { Port: 12_345 })
    end

    sleep 1 # Wait for server to launch
  end

  def teardown
    Process.kill(:INT, -Process.getpgid(@server_pid))
  end

  EXPECTED_RESPONSE_MESSAGE_FOR_GET = <<~MESSAGE
    HTTP/1.1 200 OK\r
    Content-Type: text/html\r
    Content-Length: 17\r
    \r
    Response for GET
  MESSAGE

  EXPECTED_RESPONSE_MESSAGE_FOR_OTHER = <<~MESSAGE
    HTTP/1.1 600 This is a test status code\r
    Content-Type: text/html\r
    Content-Length: 19\r
    \r
    Response for OTHER
  MESSAGE

  def test_that_it_returns_response_message
    assert_equal(
      EXPECTED_RESPONSE_MESSAGE_FOR_GET,
      execute_client("GET /posts", port: 12_345)
    )

    assert_equal(
      EXPECTED_RESPONSE_MESSAGE_FOR_OTHER,
      execute_client("OTHER /posts", port: 12_345)
    )
  end
end
