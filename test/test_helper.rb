# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "toycol"

require "minitest/autorun"

module Helper
  def setup_test_protocol
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

  def execute_client(request_message, port:)
    ::Toycol::Client.port = port
    ::Toycol::Client.execute!(request_message) do |response_message|
      return response_message
    end
  end
end
