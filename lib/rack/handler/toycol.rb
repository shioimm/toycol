# frozen_string_literal: true

require "rack"
require "rack/handler"
require "rack/handler/puma"

module Rack
  module Handler
    class Toycol
      def self.run(app, options = {})
        if (child_pid = fork)
          environment  = ENV["RACK_ENV"] || "development"
          default_host = environment == "development" ? "localhost" : "0.0.0.0"

          host = options.delete(:Host) || default_host
          port = options.delete(:Port) || "9292"

          ::Toycol::Proxy.new(host, port).start
          Process.waitpid(child_pid)
        else
          puts "Toycol starts Puma in single mode, listening on unix://#{::Toycol::UNIX_SOCKET_PATH}"
          # TODO: Make it possible to switch between Puma and the built-in server
          # Rack::Handler::Puma.run(app, **{ Host: ::Toycol::UNIX_SOCKET_PATH, Silent: true })
          ::Toycol::Server.run(app, **{ Path: ::Toycol::UNIX_SOCKET_PATH, Port: options.delete(:Port) || "9292" })
        end
      end
    end

    register :toycol, Toycol
  end
end
