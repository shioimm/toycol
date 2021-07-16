# frozen_string_literal: true

require "rack"
require "toycol"

Toycol::Protocol.use(:duck)

# Duck protocol application
class App
  def call(env)
    case env["REQUEST_METHOD"]
    when "GET"
      case env["PATH_INFO"]
      when "/posts"
        return app_for_get_with_query if env["QUERY_STRING"] == "user_id=1"

        app_for_get
      when "/" then app_for_get_to_root
      end
    when "OTHER" then app_for_other
    end
  end

  private

  def app_for_get_with_query
    [
      200,
      { "Content-Type" => "text/html" },
      ["quack quack, I am the No.1 duck\n"]
    ]
  end

  def app_for_get
    [
      200,
      { "Content-Type" => "text/html" },
      ["quack quack, quack quack, quack, quack\n", "quack quack, I am the No.1 duck\n"]
    ]
  end

  def app_for_get_to_root
    [
      200,
      { "Content-Type" => "text/html" },
      ["Hello, This app is running on Sample duck protocol.\n"]
    ]
  end

  def app_for_other
    [
      600,
      { "Content-Type" => "text/html" },
      ["Sorry, this application is only for ducks...\n"]
    ]
  end
end

run App.new
