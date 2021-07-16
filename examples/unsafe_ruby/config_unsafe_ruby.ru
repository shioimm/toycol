# frozen_string_literal: true

require "rack"
require "toycol"

Toycol::Protocol.use(:ruby)

class App
  def call(env)
    case env["REQUEST_METHOD"]
    when "GET"
      case env["PATH_INFO"]
      when "/posts"
        [
          200,
          { "Content-Type" => "text/html" },
          ["I love Ruby!\n", "I've successfully accessed using instance_eval!\n"]
        ]
      end
    end
  end
end

run App.new
