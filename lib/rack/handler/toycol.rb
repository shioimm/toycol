# frozen_string_literal: true

require "rack"
require "rack/handler"
require "rack/handler/puma"

module Rack
  module Handler
    class Toycol
      class << self
        def run(app, options = {})
          @app        = app
          @host       = options[:Host] || ::Toycol::DEFAULT_HOST
          @port       = options[:Port] || "9292"
          @app_server = options[:appserver]

          if (child_pid = fork)
            ::Toycol::Proxy.new(@host, @port).start
            Process.waitpid(child_pid)
          else
            run_application_server
          end
        end

        private

        def run_application_server
          case @app_server
          when "puma"
            puts "Toycol starts Puma in single mode, listening on unix://#{::Toycol::UNIX_SOCKET_PATH}"
            Rack::Handler::Puma.run(@app, **{ Host: ::Toycol::UNIX_SOCKET_PATH, Silent: true })
          else
            puts "Toycol starts build-in server, listening on unix://#{::Toycol::UNIX_SOCKET_PATH}"
            ::Toycol::Server.run(@app, **{ Path: ::Toycol::UNIX_SOCKET_PATH, Port: @port })
          end
        end
      end
    end

    register :toycol, Toycol
  end
end
