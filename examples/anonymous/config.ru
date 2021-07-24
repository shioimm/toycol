# frozen_string_literal: true

require "rack"
require "toycol"

Toycol::Protocol.use

class App
  def call(env)
    case env["REQUEST_METHOD"]
    when "GET"
      [
        200,
        { "Content-Type" => "text/html" },
        ["This app has no protocol name\n"]
      ]
    end
  end
end

run App.new
