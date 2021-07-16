# frozen_string_literal: true

require "rack"
require "toycol"

Toycol::Protocol.use(:rubylike)

class App
  def call(env)
    case env["REQUEST_METHOD"]
    when "GET"
      [
        200,
        { "Content-Type" => "text/html" },
        ["Hello, This app is running on Ruby like protocol."]
      ]
    when "OTHER"
      [
        700,
        { "Content-Type" => "text/html" },
        ["Sorry, but I'd like you to speak more like a Ruby programmer..."]
      ]
    end
  end
end

run App.new
