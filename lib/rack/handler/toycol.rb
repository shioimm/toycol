# frozen_string_literal: true

require "rack"
require "rack/handler"

module Rack
  module Handler
    class Toycol
      class << self
        attr_writer :preferred_background_server

        def run(app, options = {})
          @app  = app
          @host = options[:Host] || ::Toycol::DEFAULT_HOST
          @port = options[:Port] || "9292"

          if (child_pid = fork)
            ::Toycol::Proxy.new(@host, @port).start
            Process.waitpid(child_pid)
          else
            run_background_server
          end
        end

        private

        def select_background_server
          case @preferred_background_server
          when "puma"
            return "puma" if puma_requireable?

            puts "Puma is not installed in your environment."
            raise LoadError
          when nil
            puma_requireable? ? "puma" : "build_in"
          else
            "build_in"
          end
        end

        def puma_requireable?
          require "rack/handler/puma"
          true
        rescue LoadError
          false
        end

        def run_background_server
          case select_background_server
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
