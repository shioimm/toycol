# frozen_string_literal: true

require "rack/handler"

module Rack
  module Handler
    class Toycol
      extend ::Toycol::Helper

      class << self
        attr_writer :preferred_background_server, :host, :port

        def run(app, _ = {})
          @app = app
          @host ||= ::Toycol::DEFAULT_HOST
          @port ||= "9292"

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

            raise LoadError, "Puma is not installed in your environment."
          when nil
            puma_requireable? ? "puma" : "build_in"
          else
            "build_in"
          end
        rescue LoadError
          Process.kill(:INT, Process.ppid)
          abort
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
            logger "Start Puma in single mode, listening on unix://#{::Toycol::UNIX_SOCKET_PATH}"
            Rack::Handler::Puma.run(@app, **{ Host: ::Toycol::UNIX_SOCKET_PATH, Silent: true })
          else
            logger "Start build-in server, listening on unix://#{::Toycol::UNIX_SOCKET_PATH}"
            ::Toycol::Server.run(@app, **{ Path: ::Toycol::UNIX_SOCKET_PATH, Port: @port })
          end
        end
      end
    end

    register :toycol, Toycol
  end
end
