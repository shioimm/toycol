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
end
