# frozen_string_literal: true

require "test_helper"

class ProtocolTest < Minitest::Test
  def setup
    Toycol::Protocol.define(:test) do
      custom_status_codes(600 => "This is a test status code")
      additional_request_methods "OTHER"
      request.path  { |message| %r{(?<path>/\w*)}.match(message)[:path] }
      request.query { |message| /\?(?<query>.+)/.match(message) { |m| m[:query] } }
      request.http_method { |message| /^(?<http_method>\w+)\b/.match(message) { |m| m[:http_method] }.upcase }
      request.input       { |message| message.lines.last }
    end

    Toycol::Protocol.use(:test)
  end

  def test_that_it_defines_protocol_name
    Toycol::Protocol.run!("GET /posts?user_id=1")

    assert_equal(
      :test,
      Toycol::Protocol.instance_variable_get("@definements").keys.first
    )
  end

  def test_that_it_uses_specified_protocol_name
    Toycol::Protocol.run!("GET /posts?user_id=1")

    assert_equal(
      :test,
      Toycol::Protocol.instance_variable_get("@protocol_name")
    )
  end

  def test_that_it_returns_request_path
    Toycol::Protocol.run!("GET /posts")

    assert_equal(
      "/posts",
      Toycol::Protocol.request_path
    )
  end

  def test_that_it_returns_error_when_size_is_too_long
    Toycol::Protocol.run!("GET /#{"posts" * 2048}")

    error = assert_raises Toycol::UnauthorizedRequestError do
      Toycol::Protocol.request_path
    end

    assert_equal(
      "This request path is too long",
      error.message
    )
  end

  def test_that_it_returns_error_when_contains_unauthorized_character
    Toycol::Protocol.define(:test) { request.path { "/p+o+s+t+s" } }
    Toycol::Protocol.run!("GET /p+o+s+t+s")

    error = assert_raises Toycol::UnauthorizedRequestError do
      Toycol::Protocol.request_path
    end

    assert_equal(
      "This request path contains unauthorized character",
      error.message
    )
  end

  def test_that_it_returns_request_method
    Toycol::Protocol.run!("GET /posts")

    assert_equal(
      "GET",
      Toycol::Protocol.request_method
    )
  end

  def test_that_it_returns_error_when_is_not_defined
    Toycol::Protocol.run!("UNDEFINED /posts")

    error = assert_raises Toycol::UndefinedRequestMethodError do
      Toycol::Protocol.request_method
    end

    assert_equal(
      "This request method is undefined",
      error.message
    )
  end

  def test_that_it_returns_query
    Toycol::Protocol.run!("GET /posts?user_id=1")

    assert_equal(
      "user_id=1",
      Toycol::Protocol.query
    )
  end

  def test_that_it_returns_input
    Toycol::Protocol.run!("POST /posts\r\nThis is test.")

    assert_equal(
      "This is test.",
      Toycol::Protocol.input
    )
  end
end
