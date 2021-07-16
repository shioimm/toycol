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
        ["I love ruby!\n", "I love RubyKaigi!\n"]
      ]
    when "OTHER"
      [
        700,
        { "Content-Type" => "text/html" },
        ["Sorry, but I'd like you to speak more like a Ruby programmer...\n"]
      ]
    end
  end
end

run App.new
