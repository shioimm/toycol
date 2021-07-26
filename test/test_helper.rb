# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "toycol"

require "minitest/autorun"

module Helper
  def setup_test_protocol
    protocol_name = "test_#{rand((999..999_999).to_a.sample)}".to_sym

    Toycol::Protocol.define(protocol_name) do
      custom_status_codes(600 => "This is a test status code")
      additional_request_methods "OTHER"
      request.path  { |message| %r{(?<path>/\w*)}.match(message)[:path] }
      request.query { |message| /\?(?<query>.+)/.match(message) { |m| m[:query] } }
      request.http_method { |message| /^(?<http_method>\w+)\b/.match(message) { |m| m[:http_method] }.upcase }
      request.input       { |message| message.lines.size > 1 ? message.lines.last : nil }
    end

    Toycol::Protocol.use(protocol_name)
  end

  def execute_client(request_message, port:)
    ::Toycol::Client.port = port
    ::Toycol::Client.execute!(request_message) do |response_message|
      return response_message
    end
  end
end
