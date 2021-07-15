# frozen_string_literal: true

require "rack/handler"
require "rack/handler/puma"

module Rack
  module Handler
    class Toycol
      def self.run(app, options = {})
        if (child_pid = fork)
          puts "Toycol starts Puma in single mode, listening on unix://#{::Toycol::UNIX_SOCKET_PATH}"
          Rack::Handler::Puma.run(app, **{ Host: ::Toycol::UNIX_SOCKET_PATH, Silent: true })
          Process.waitpid(child_pid)
        else
          environment  = ENV["RACK_ENV"] || "development"
          default_host = environment == "development" ? "localhost" : "0.0.0.0"

          host = options.delete(:Host) || default_host
          port = options.delete(:Port) || "9292"

          ::Toycol::Proxy.new(host, port).start
        end
      end
    end

    register :toycol, Toycol
  end
end
