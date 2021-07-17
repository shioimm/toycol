# frozen_string_literal: true

require "rack"
require "toycol"

Toycol::Protocol.use(:safe_ruby)

class App
  def call(env)
    case env["REQUEST_METHOD"]
    when "GET"
      case env["PATH_INFO"]
      when "/posts"
        return app_for_get_with_query if env["QUERY_STRING"] == "user_id=2"

        app_for_get
      end
    when "POST"
      input   = env["rack.input"].gets
      created = input.split("&").map { |str| str.split("=") }.to_h

      app_for_post(user_id: created["user_id"], body: created["body"])
    end
  end

  private

  def app_for_get_with_query
    [
      200,
      { "Content-Type" => "text/html" },
      ["User<2> I love RubyKaigi!\n"]
    ]
  end

  def app_for_get
    [
      200,
      { "Content-Type" => "text/html" },
      ["User<1> I love Ruby!\n", "User<2> I love RubyKaigi!\n"]
    ]
  end

  def app_for_post(user_id:, body:)
    [
      201,
      { "Content-Type" => "text/html", "Location" => "/posts" },
      ["User<1> I love Ruby!\n",
       "User<2> I love RubyKaigi!\n",
       "User<#{user_id}> #{body}\n"]
    ]
  end
end

run App.new
