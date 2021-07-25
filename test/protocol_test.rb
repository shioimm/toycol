# frozen_string_literal: true

require_relative "test_helper"

class ProtocolTest < Minitest::Test
  include Helper

  def test_that_it_defines_protocol_name
    Toycol::Protocol.define(:protocol_test_define1) { "protocol_test_define1" }
    Toycol::Protocol.use(:protocol_test_define1)

    assert_equal(
      "protocol_test_define1",
      Toycol::Protocol.instance_variable_get("@definements")[:protocol_test_define1].call
    )
  end

  def test_that_it_returns_error_when_there_are_two_duplucate_protocols
    error = assert_raises Toycol::DuplicateProtocolError do
      Toycol::Protocol.define(:protocol_test_define2) { "protocol_test_define2_1" }
      Toycol::Protocol.define(:protocol_test_define2) { "protocol_test_define2_2" }
    end

    assert_equal(
      "protocol_test_define2 protocol has already been defined",
      error.message
    )
  end

  def test_that_it_uses_specified_protocol_name
    Toycol::Protocol.define(:protocol_test_use1) { "protocol_test_use1" }
    Toycol::Protocol.use(:protocol_test_use1)

    assert_equal(
      :protocol_test_use1,
      Toycol::Protocol.instance_variable_get("@protocol_name")
    )
  end

  def test_that_it_returns_request_path
    setup_test_protocol
    Toycol::Protocol.run!("GET /posts")

    assert_equal(
      "/posts",
      Toycol::Protocol.request_path
    )
  end

  def test_that_it_returns_error_when_size_is_too_long
    setup_test_protocol
    Toycol::Protocol.run!("GET /#{"posts" * 2048}")

    error = assert_raises Toycol::UnauthorizeError do
      Toycol::Protocol.request_path
    end

    assert_equal(
      "This request path is too long",
      error.message
    )
  end

  def test_that_it_returns_error_when_contains_unauthorized_character
    Toycol::Protocol.define(:protocol_test_request_path1) do
      request.path { "/p+o+s+t+s" }
      request.http_method { |message| /^(?<http_method>\w+)\b/.match(message) { |m| m[:http_method] }.upcase }
    end

    Toycol::Protocol.use(:protocol_test_request_path1)
    Toycol::Protocol.run!("GET /p+o+s+t+s")

    error = assert_raises Toycol::UnauthorizeError do
      Toycol::Protocol.request_path
    end

    assert_equal(
      "This request path contains unauthorized character",
      error.message
    )
  end

  def test_that_it_returns_request_method
    setup_test_protocol
    Toycol::Protocol.run!("GET /posts")

    assert_equal(
      "GET",
      Toycol::Protocol.request_method
    )
  end

  def test_that_it_returns_error_when_is_not_defined
    setup_test_protocol
    Toycol::Protocol.run!("UNDEFINED /posts")

    error = assert_raises Toycol::UndefinementError do
      Toycol::Protocol.request_method
    end

    assert_equal(
      "This request method is undefined",
      error.message
    )
  end

  def test_that_it_returns_query
    setup_test_protocol
    Toycol::Protocol.run!("GET /posts?user_id=1")

    assert_equal(
      "user_id=1",
      Toycol::Protocol.query
    )
  end

  def test_that_it_returns_input
    setup_test_protocol
    Toycol::Protocol.run!("POST /posts\r\nThis is test.")

    assert_equal(
      "This is test.",
      Toycol::Protocol.input
    )
  end

  def test_that_it_returns_default_http_status_message
    setup_test_protocol
    Toycol::Protocol.run!("GET /posts")

    assert_equal(
      "OK",
      Toycol::Protocol.status_message(200)
    )
  end

  def test_that_it_returns_custom_http_status_message
    setup_test_protocol
    Toycol::Protocol.run!("GET /posts")

    assert_equal(
      "This is a test status code",
      Toycol::Protocol.status_message(600)
    )
  end

  def test_that_it_returns_error_when_status_code_is_not_defined
    setup_test_protocol
    Toycol::Protocol.run!("GET /posts")

    error = assert_raises Toycol::HTTPError do
      Toycol::Protocol.status_message(700)
    end

    assert_equal(
      "Application returns unknown status code",
      error.message
    )
  end
end
